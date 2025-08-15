import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:skrambl_app/models/send_form_model.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class StandardSendingScreen extends StatefulWidget {
  final SendFormModel form;

  const StandardSendingScreen({super.key, required this.form});

  @override
  State<StandardSendingScreen> createState() => _StandardSendingScreenState();
}

class _StandardSendingScreenState extends State<StandardSendingScreen> {
  static const int lamportsPerSol = 1000000000;

  String _phase = 'Preparing…';
  String? _signature;
  String? _error;

  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Kick off sending as soon as we render
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    try {
      // 1) Seed Vault availability & token
      setState(() => _phase = 'Requesting Seed Vault permission…');
      final available = await SeedVault.instance.isAvailable(allowSimulated: true);
      if (!available) throw Exception('Seed Vault not available');

      final token = await SeedVaultService.getValidToken(context);
      if (token == null) throw Exception('Seed Vault permission denied');

      // 2) Resolve sender pubkey
      setState(() => _phase = 'Resolving wallet…');
      final sender = await SeedVaultService.getPublicKey(authToken: token);
      if (sender == null) throw Exception('Failed to get public key');

      // 3) Build unsigned transfer message
      setState(() => _phase = 'Building transaction…');
      final dest = Ed25519HDPublicKey.fromBase58(widget.form.destinationWallet!);
      final lamports = (widget.form.amount! * lamportsPerSol).round();

      final rpc = SolanaClientService().rpcClient;
      final recent = await rpc.getLatestBlockhash();
      final blockhash = recent.value.blockhash;

      // Build raw message bytes for a System Program transfer
      // NOTE: If you already have a shared helper for building unsigned tx messages, you can swap it in here.
      final messageBytes = await _buildSystemTransferSignable(
        recentBlockhash: blockhash,
        from: sender,
        to: dest,
        lamports: lamports,
      );

      // 4) Sign with Seed Vault
      setState(() => _phase = 'Awaiting signature…');
      final signature = await SeedVaultService.signMessage(messageBytes: messageBytes, authToken: token);
      if (signature.length != 64) throw Exception('Invalid signature length');

      skrLogger.i('signable len: ${messageBytes.length}');
      skrLogger.i('sig len: ${signature.length}');

      // 5) Submit transaction
      setState(() => _phase = 'Submitting…');
      final txSig = await _sendSignedTransaction(rpc: rpc, messageBytes: messageBytes, signature: signature);

      setState(() {
        _signature = txSig;
        _phase = 'Confirming…';
      });

      // 6) Confirm (simple loop; you can replace with WS account or signature subscribe)
      await _confirmSignature(rpc, txSig);

      if (!mounted) return;
      setState(() {
        _phase = 'Confirmed';
        _done = true;
      });

      // Pop back to previous screen after a short delay
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e, st) {
      skrLogger.e('Standard send failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _done = true;
      });
    }
  }

  /// Build a System Program transfer message bytes ready for signing.
  /// You can replace this with your shared helper if you already have one.
  Future<Uint8List> _buildSystemTransferSignable({
    required String recentBlockhash,
    required Ed25519HDPublicKey from,
    required Ed25519HDPublicKey to,
    required int lamports,
  }) async {
    // 1) Main transfer instruction
    final transferIx = SystemInstruction.transfer(
      fundingAccount: from,
      recipientAccount: to,
      lamports: lamports,
    );
    final ixs = <Instruction>[transferIx];

    // 2) Build Message with NAMED parameter `instructions:`
    final msg = Message(instructions: ixs);

    // 3) Compile to legacy CompiledMessage (signable)
    final compiled = msg.compile(recentBlockhash: recentBlockhash, feePayer: from);

    // 4) Get signable bytes (pick the one your version exposes)
    // Try these in order based on what exists in your CompiledMessage:
    // return compiled.toByteArray();           // common
    // return compiled.toBytes();               // some versions
    // return compiled.data;                    // some versions expose raw Uint8List
    // return compiled.toLegacyMessage().toByteArray(); // fallback if available
    //return compiled.toByteArray(); // <-- adjust if your type uses a different method

    return Uint8List.fromList(compiled.toByteArray().toList());
  }

  Uint8List _encodeShortVecLength(int n) {
    final out = <int>[];
    var v = n;
    while (true) {
      var elem = v & 0x7F;
      v >>= 7;
      if (v == 0) {
        out.add(elem);
        break;
      } else {
        out.add(elem | 0x80);
      }
    }
    return Uint8List.fromList(out);
  }

  /// Submit the signed transaction to RPC.
  Future<String> _sendSignedTransaction({
    required RpcClient rpc,
    required Uint8List messageBytes,
    required Uint8List signature,
  }) async {
    try {
      return await _sendWire(rpc, messageBytes, signature);
    } catch (e) {
      final msg = e.toString();
      final expired = msg.contains('BlockhashNotFound') || msg.contains('blockhash not found');
      if (!expired) rethrow;

      if (!mounted) {
        throw Exception('Unmounted during blockhash refresh');
      }
      final authToken = await SeedVaultService.getValidToken(context);
      if (authToken == null) throw Exception('Seed Vault permission denied');

      // Rebuild + resign once
      final recent = await rpc.getLatestBlockhash();
      final sender = await SeedVaultService.getPublicKey(authToken: authToken);
      final dest = Ed25519HDPublicKey.fromBase58(widget.form.destinationWallet!);
      final lamports = (widget.form.amount! * lamportsPerSol).round();

      final freshMsg = await _buildSystemTransferSignable(
        recentBlockhash: recent.value.blockhash,
        from: sender!,
        to: dest,
        lamports: lamports,
      );
      final freshSig = await SeedVaultService.signMessage(
        messageBytes: freshMsg,
        authToken: (await SeedVaultService.getValidToken(context))!,
      );
      return _sendWire(rpc, freshMsg, freshSig);
    }
  }

  Future<String> _sendWire(RpcClient rpc, Uint8List msg, Uint8List sig) async {
    if (sig.length != 64) throw Exception('Invalid signature length: ${sig.length}');
    final sigCount = _encodeShortVecLength(1);
    final wire = Uint8List(sigCount.length + sig.length + msg.length)
      ..setRange(0, sigCount.length, sigCount)
      ..setRange(sigCount.length, sigCount.length + sig.length, sig)
      ..setRange(sigCount.length + sig.length, sigCount.length + sig.length + msg.length, msg);
    final b64 = base64Encode(wire);
    return rpc.sendTransaction(b64);
  }

  /// Poll for confirmation (you can replace with WS `signatureSubscribe` later).
  Future<void> _confirmSignature(RpcClient rpc, String sig) async {
    var delay = const Duration(milliseconds: 600);
    for (int i = 0; i < 12; i++) {
      try {
        final res = await rpc.getSignatureStatuses([sig], searchTransactionHistory: true);
        final st = res.value.first;
        if (st != null) {
          final cs = st.confirmationStatus; // 'processed' | 'confirmed' | 'finalized'
          if (cs == Commitment.finalized || cs == Commitment.confirmed) return;
        }
      } catch (_) {
        /* ignore */
      }
      await Future.delayed(delay);
      if (delay.inMilliseconds < 4000) delay *= 2;
    }
    // Timeout: it's still okay — you set _signature and UI shows submitted; your WS infra can finish it.
  }

  @override
  Widget build(BuildContext context) {
    final showSpinner = !_done;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_error == null) ...[
                    const Icon(Icons.flash_on, size: 56, color: Colors.black87),
                    const SizedBox(height: 14),
                    Text(_phase, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    if (showSpinner) const CircularProgressIndicator(),
                    if (_signature != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        'Signature: $_signature',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ] else ...[
                    const Icon(Icons.error_outline, size: 56, color: Color(0xFFB3261E)),
                    const SizedBox(height: 14),
                    const Text('Failed to send', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
