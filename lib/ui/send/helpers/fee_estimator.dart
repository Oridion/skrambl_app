// lib/solana/fee_estimator.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:solana/solana.dart';

import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/constants/app.dart'; // for your RPC URL

Future<int> getSingleSignatureFee() async {
  final rpc = SolanaClientService().rpcClient;

  try {
    // Get a fresh blockhash (includes fee calculator info)
    final latest = await rpc.getLatestBlockhash();
    return latest.value.feeCalculator.lamportsPerSignature;
  } catch (e) {
    // Fail-safe: fallback to ~5000 lamports (default)
    return 5000;
  }
}

// class FeeEstimate {
//   final int baseLamports;
//   final int priorityLamports;
//   FeeEstimate({required this.baseLamports, this.priorityLamports = 0});

//   int get totalLamports => baseLamports + priorityLamports;
//   double get baseSol => baseLamports / 1e9;
//   double get prioritySol => priorityLamports / 1e9;
//   double get totalSol => totalLamports / 1e9;
// }

// class FeeEstimator {
//   final RpcClient _rpc = SolanaClientService().rpcClient;

//   /// Conservative CU budget for a simple System transfer.
//   static const int _defaultCuBudget = 10_000;

//   Future<FeeEstimate> estimateTransferFee({
//     required Ed25519HDPublicKey from,
//     required Ed25519HDPublicKey to,
//     required int lamports,
//     bool includePrioritySuggestion = false,
//     int cuBudget = _defaultCuBudget,
//     Commitment commitment = Commitment.confirmed,
//   }) async {
//     try {
//       // 1) Build message
//       final ix = SystemInstruction.transfer(fundingAccount: from, recipientAccount: to, lamports: lamports);
//       final msg = Message(instructions: [ix]);

//       // 2) Compile with a fresh blockhash
//       final recent = await _rpc.getLatestBlockhash();
//       final compiled = msg.compile(recentBlockhash: recent.value.blockhash, feePayer: from);

//       // 3) Base fee via getFeeForMessage (base64)
//       final msgBytes = Uint8List.fromList(compiled.toByteArray().toList());
//       final base64Message = base64Encode(msgBytes);

//       final base = await _rpc.getFeeForMessage(base64Message, commitment: commitment) ?? 0;

//       if (!includePrioritySuggestion) {
//         return FeeEstimate(baseLamports: base);
//       }

//       // 4) Optional: priority suggestion (μlamports/CU -> lamports)
//       final microLamportsPerCu = await _fetchMedianMicroLamportsPerCu();
//       final priority = microLamportsPerCu == null ? 0 : (microLamportsPerCu * cuBudget) ~/ 1_000_000;

//       return FeeEstimate(baseLamports: base, priorityLamports: priority);
//     } catch (_) {
//       // Fail-safe: never break the UI
//       return FeeEstimate(baseLamports: 0, priorityLamports: 0);
//     }
//   }

//   /// Calls `getRecentPrioritizationFees` manually via HTTP JSON-RPC.
//   /// Returns the median μlamports per CU, or null on any failure.
//   Future<int?> _fetchMedianMicroLamportsPerCu() async {
//     try {
//       final payload = {"jsonrpc": "2.0", "id": 1, "method": "getRecentPrioritizationFees", "params": []};

//       final res = await http
//           .post(
//             Uri.parse(AppConstants.rawAPIURL),
//             headers: {"Content-Type": "application/json"},
//             body: jsonEncode(payload),
//           )
//           .timeout(const Duration(seconds: 4));

//       if (res.statusCode != 200) return null;
//       final body = jsonDecode(res.body);
//       final list = (body['result'] as List?) ?? [];
//       if (list.isEmpty) return null;

//       final nums = list.map((e) => (e['prioritizationFee'] as num).toInt()).where((n) => n >= 0).toList()
//         ..sort();

//       return nums.isEmpty ? null : nums[nums.length ~/ 2];
//     } catch (_) {
//       return null;
//     }
//   }
// }
