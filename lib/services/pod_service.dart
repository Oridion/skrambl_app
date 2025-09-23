import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/constants/program_id.dart';
import 'package:skrambl_app/models/pod_model.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:solana/dto.dart';
import 'package:skrambl_app/utils/logger.dart';

/// Parse a Pod from raw account bytes (including discriminator).
Future<Pod?> parsePod(List<int> raw) async {
  final pod = Pod.fromAccountData(raw);
  if (pod == null) {
    skrLogger.w("Failed to parse Pod from bytes (len=${raw.length})");
  }
  return pod;
}

/// Fetch a Pod account by PDA.
Future<Pod?> fetchPodAccount({required String podPda}) async {
  final rpc = SolanaClientService().rpcClient;
  try {
    final accountInfo = await rpc.getAccountInfo(
      podPda,
      encoding: Encoding.base64,
      commitment: Commitment.confirmed,
    );

    final value = accountInfo.value;
    if (value == null || value.owner != programId) return null;

    final data = value.data;
    if (data is! BinaryAccountData) return null;

    final raw = Uint8List.fromList(data.data); // includes disc
    return Pod.fromAccountData(raw, debugLabel: podPda);
  } catch (e, st) {
    skrLogger.w('fetchPodAccount error: $e\n$st');
    return null;
  }
}

/// Snapshot of Pod account state
class PodSnapshot {
  final Pod? pod;
  final bool exists;
  final bool ownerMatches;
  final bool isClosedFinalized;

  PodSnapshot({
    required this.pod,
    required this.exists,
    required this.ownerMatches,
    required this.isClosedFinalized,
  });
}

/// Fetch Pod snapshot with confirmed + finalized checks
Future<PodSnapshot> fetchPodSnapshot(String podPda) async {
  final rpc = SolanaClientService().rpcClient;

  try {
    final liveInfo = await rpc.getAccountInfo(
      podPda,
      encoding: Encoding.base64,
      commitment: Commitment.confirmed,
    );

    Pod? pod;
    bool exists = false;
    bool ownerMatches = false;
    bool isClosedFinalized = false;

    final live = liveInfo.value;
    if (live != null) {
      exists = true;
      ownerMatches = (live.owner == programId);

      if (ownerMatches) {
        final data = live.data;
        if (data is BinaryAccountData) {
          final raw = Uint8List.fromList(data.data);
          pod = await parsePod(raw);
        } else {
          skrLogger.w('[RPC] Unexpected data type: ${data.runtimeType}');
        }
      } else {
        skrLogger.w('[RPC] Owner mismatch: ${live.owner} != $programId');
      }
    } else {
      final finalInfo = await rpc.getAccountInfo(
        podPda,
        encoding: Encoding.base64,
        commitment: Commitment.finalized,
      );
      isClosedFinalized = (finalInfo.value == null);
    }

    return PodSnapshot(
      pod: pod,
      exists: exists,
      ownerMatches: ownerMatches,
      isClosedFinalized: isClosedFinalized,
    );
  } catch (e, st) {
    skrLogger.w('fetchPodSnapshot[$podPda] error: $e\n$st');
    return PodSnapshot(pod: null, exists: false, ownerMatches: false, isClosedFinalized: false);
  }
}

/// Direct fetch (manual JSON-RPC)
Future<Pod?> fetchPod(String podPda, String commitment) async {
  final payload = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getAccountInfo",
    "params": [
      podPda,
      {"encoding": "base64", "commitment": commitment},
    ],
  };

  final response = await http.post(
    Uri.parse(AppConstants.rawAPIURL),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(payload),
  );

  if (response.statusCode != 200) return null;

  final json = jsonDecode(response.body);
  final base64Data = json['result']?['value']?['data']?[0];
  if (base64Data == null) return null;

  final rawBytes = base64.decode(base64Data);
  skrLogger.i('fetchPod[$podPda/$commitment] rawLen=${rawBytes.length}');
  return Pod.fromAccountData(rawBytes, debugLabel: '$podPda/$commitment');
}
