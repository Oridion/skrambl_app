import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import 'dart:async';

Future<Uint8List> updateBlockhashInMessage(Uint8List messageBytes) async {
  final rpcClient = RpcClient('https://mainnet.helius-rpc.com/?api-key=e9be3c89-9113-4c5d-be19-4dfc99d8c8f4');

  // Get the latest blockhash from the cluster
  final latestBlockhash = await rpcClient.getLatestBlockhash();
  final freshBlockhash = latestBlockhash.value.blockhash;
  skrLogger.i("🔄 Fresh blockhash: $freshBlockhash");
  final freshBlockhashBytes = base58decode(freshBlockhash);

  // Parse the message to find where blockhash starts
  int offset = 0;

  // Skip header (3 bytes)
  offset += 3;

  // Decode compact-u16 account count
  int accountCount = messageBytes[offset];
  offset += 1;
  if (accountCount & 0x80 != 0) {
    // two-byte form
    accountCount = (accountCount & 0x7F) | (messageBytes[offset] << 7);
    offset += 1;
  }

  // Skip account public keys (32 bytes each)
  offset += accountCount * 32;

  // Overwrite the blockhash bytes in place
  final patched = Uint8List.fromList(messageBytes);
  patched.setRange(offset, offset + 32, freshBlockhashBytes);
  //skrLogger.i("🔄 Patched blockhash at offset $offset with $freshBlockhash");

  assert(base58encode(patched.sublist(offset, offset + 32)) == freshBlockhash, "Blockhash patch failed");
  return patched;
}

Future<void> sendSignedTx(Uint8List txBytes, Uint8List signature) async {
  final rpcClient = RpcClient("https://mainnet.helius-rpc.com/?api-key=e9be3c89-9113-4c5d-be19-4dfc99d8c8f4");

  // Append the signature manually
  final signedTx = Uint8List.fromList([
    ...signature,
    ...txBytes.sublist(64), // Skip the first 64 bytes (empty sig)
  ]);

  //skrLogger.i("txBytes length: ${txBytes.length}");
  //skrLogger.i("signedTx length: ${signedTx.length}");
  assert(txBytes.length == signedTx.length, "Mismatch in tx length!");

  final base64Tx = base64Encode(signedTx);

  try {
    await rpcClient.sendTransaction(base64Tx, preflightCommitment: Commitment.confirmed);
    //skrLogger.i("🚀 Sent! Signature: $sig");
  } catch (e) {
    skrLogger.e("❌ Failed to send transaction: $e");
  }
}

Future<String> sendTransactionWithRetry(
  Uint8List txBytes,
  Uint8List signature,
  int maxRetries,
  void Function(TransactionPhase phase)? onPhaseChange, // optional callback
) async {
  final RpcClient rpcClient = AppConstants.rpcClient;

  String? lastError;
  int attempt = 0;

  // Helper: compact-u16 encoding for signature count
  List<int> compactU16(int value) {
    if (value < 0x80) {
      return [value];
    } else {
      return [(value & 0x7F) | 0x80, (value >> 7) & 0x7F];
    }
  }

  while (attempt < maxRetries) {
    try {
      // Build signed transaction
      final signedTx = Uint8List.fromList([
        ...compactU16(1), // 1 signature
        ...signature, // 64-byte signature
        ...txBytes, // message
      ]);

      // Notify UI: sending
      onPhaseChange?.call(TransactionPhase.sending);

      //skrLogger.i("📦 Attempt ${attempt + 1} — tx length: ${signedTx.length}");

      // Send transaction
      final base64Tx = base64Encode(signedTx);
      final sig = await rpcClient.sendTransaction(
        base64Tx,
        skipPreflight: false,
        preflightCommitment: Commitment.confirmed,
      );

      //skrLogger.i("📨 Sent transaction: $sig — waiting for finalization…");

      // Notify UI: confirming
      onPhaseChange?.call(TransactionPhase.confirming);

      // Wait for confirmation
      final isFinalized = await _confirmFinalizedSignature(rpcClient, sig);

      if (isFinalized) {
        //skrLogger.i("Finalized: $sig");
        return sig;
      } else {
        skrLogger.w("Not finalized yet, retrying…");
      }
    } catch (e) {
      lastError = e.toString();
      skrLogger.w("Send attempt ${attempt + 1} failed: $lastError");

      // Refresh blockhash if expired
      if (lastError.contains("BlockhashNotFound")) {
        txBytes = await updateBlockhashInMessage(txBytes);
        //skrLogger.i("🔄 Blockhash refreshed for retry");
      }
    }

    // Delay before retry
    attempt++;
    if (attempt < maxRetries) {
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  // ❌ Fail if never finalized
  onPhaseChange?.call(TransactionPhase.failed);
  skrLogger.e("💥 Failed after $maxRetries attempts: $lastError");
  throw Exception("Transaction failed: $lastError");
}

Future<bool> _confirmFinalizedSignature(
  RpcClient client,
  String signature, {
  int maxChecks = 10,
  Duration delay = const Duration(seconds: 2),
}) async {
  for (int i = 0; i < maxChecks; i++) {
    try {
      final statusResponse = await client.getSignatureStatuses(
        [signature],
        searchTransactionHistory: true, // search history for older sigs
      );

      final status = statusResponse.value.first;

      if (status == null) {
        //skrLogger.i("⏳ [$i/$maxChecks] Transaction not found yet…");
      } else if (status.err != null) {
        skrLogger.e("❌ Transaction failed: ${status.err}");
        return false; // fail immediately on error
      } else if (status.confirmations == null) {
        //skrLogger.i("✅ Transaction finalized: $signature");
        return true;
      } else {
        // skrLogger.i(
        //   "⌛ [$i/$maxChecks] Confirmations: ${status.confirmations} — Not finalized yet",
        // );
      }
    } catch (e) {
      skrLogger.e("⚠️ Error while checking status: $e");
    }

    await Future.delayed(delay);
  }

  skrLogger.e("❌ Transaction not finalized after $maxChecks checks.");
  return false;
}

class QueueInstantPodRequest {
  final String pod;
  final String signature;

  QueueInstantPodRequest({required this.pod, required this.signature});

  Map<String, dynamic> toJson() => {'pod': pod, 'signature': signature};
}

Future<bool> queueInstantPod(QueueInstantPodRequest request) async {
  final url = Uri.parse('https://api.oridion.xyz/pod/instant/queue');

  final response = await http
      .post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(request.toJson()))
      .timeout(const Duration(seconds: 20));

  if (response.statusCode == 200) {
    skrLogger.i("✅ Pod travel queued successfully.");
    return true;
  } else {
    skrLogger.e("❌ Failed to queue pod: ${response.body}");
    return false;
  }
}
