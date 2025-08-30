import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/constants/program_id.dart';
import 'package:skrambl_app/models/activity_model.dart';
import 'package:skrambl_app/models/pod_model.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:solana/dto.dart';
import 'dart:typed_data';
import 'package:skrambl_app/utils/logger.dart';

/// Stub: replace with your real parser (Anchor/Borsh).
/// Return the on-chain 'lastProcess' field from account bytes.
// Future<int?> parseLastProcessFrom(List<int> bytes) async {
//   skrLogger.i("Parsing Pod from bytes: ${bytes.length} bytes");
//   Pod? pod = Pod.fromAccountData(bytes);
//   if (pod == null) {
//     skrLogger.w("Failed to parse Pod from bytes");
//     return null;
//   }
//   return pod.lastProcess;
// }

// I need to return an object ready to be
Future<Pod?> parsePod(List<int> bytes) async {
  skrLogger.i("Parsing Pod from bytes: ${bytes.length} bytes");
  Pod? pod = Pod.fromAccountData(bytes);
  if (pod == null) {
    skrLogger.w("Failed to parse Pod from bytes");
    return null;
  }
  return pod;
}

//Tune these to your layout:
const int _kFixedSize = 150; // fields up to passcode_hash
const int _kLogEntrySize = 13;
const int _kMaxEntries = 10;
const int _kLogsRegionSize = _kLogEntrySize * _kMaxEntries; // 130
const int _kIndexOffset = _kFixedSize + _kLogsRegionSize; // 280
const int _kAnchorDisc = 8;

Future<Pod?> fetchPodAccount({
  required String podPda, // your program id (base58)
}) async {
  final rpc = SolanaClientService().rpcClient;

  try {
    final accountInfo = await rpc.getAccountInfo(
      podPda,
      encoding: Encoding.base64,
      commitment: Commitment.confirmed,
    );

    final value = accountInfo.value;
    if (value == null) {
      // account missing at this commitment
      return null;
    }

    // Safety: owner must be your program
    // Owner check note:
    // - Only check owner after confirming value != null.
    // - Owner **must** equal your on-chain program id (not the creator wallet).
    if (value.owner != programId) {
      skrLogger.w('Pod owner mismatch (got ${value.owner}), skipping decode');
      return null;
    }

    final data = value.data;
    if (data is! BinaryAccountData) {
      skrLogger.w('Unexpected data format for pod account');
      return null;
    }

    // Raw bytes including Anchor discriminator at the front
    final raw = Uint8List.fromList(data.data);
    return _parsePodFromBytes(raw);
  } catch (e, st) {
    skrLogger.w('fetchPodAccount error: $e\n$st');
    return null;
  }
}

class PodSnapshot {
  final Pod? pod;
  final bool exists; // account exists at the checked commitment
  final bool ownerMatches; // if exists, does owner == programId ?
  final bool isClosedFinalized; // final 'closed' proof (value==null at finalized)
  PodSnapshot({
    required this.pod,
    required this.exists,
    required this.ownerMatches,
    required this.isClosedFinalized,
  });
}

Future<PodSnapshot> fetchPodSnapshot(String podPda) async {
  final rpc = SolanaClientService().rpcClient;

  try {
    // 1) Fast path (confirmed)
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

      if (!ownerMatches) {
        skrLogger.w('[RPC] Owner mismatch: ${live.owner} != $programId (skip decode)');
      } else {
        final data = live.data;
        if (data is! BinaryAccountData) {
          // Per your guarantee this shouldn’t happen; log and bail safely.
          skrLogger.w('[RPC] Unexpected data type: ${data.runtimeType}');
        } else {
          final raw = data.data; // Uint8List (includes 8-byte Anchor discriminator)
          pod = await parsePod(raw); // uses fromAccountData -> fromBuffer
        }
      }
    } else {
      // 2) Looks closed at confirmed → double-check at finalized
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

/// Decode helper that tolerates different RPC data shapes.
// Uint8List? _extractBytes(dynamic data) {
//   // BinaryAccountData (solana package)
//   if (data is BinaryAccountData) {
//     return Uint8List.fromList(data.data);
//   }
//   // Some clients return ["<base64>", "<encoding>"]
//   if (data is List && data.isNotEmpty && data.first is String) {
//     final s = data.first as String;
//     if (s.isEmpty) return Uint8List(0);
//     try {
//       return base64.decode(s);
//     } catch (_) {
//       return null;
//     }
//   }
//   return null;
// }

/// Parses a Pod from raw account bytes (skipping anchor disc and reading logs).
Pod? _parsePodFromBytes(Uint8List raw) {
  if (raw.length < _kAnchorDisc + _kFixedSize) {
    skrLogger.w('Pod too small: ${raw.length}');
    return null;
  }
  final base = _kAnchorDisc;

  // 1) fixed region
  final fixedSlice = raw.sublist(base, base + _kFixedSize);
  final decoded = Pod.shortCodec.decode(fixedSlice); // your existing codec

  // 2) logs (compact)
  final remaining = raw.length - base - _kFixedSize;
  final logsAvail = remaining.clamp(0, _kLogsRegionSize);
  final entries = logsAvail ~/ _kLogEntrySize;

  final log = <ActivityEntry>[];
  for (int i = 0; i < entries; i++) {
    final start = base + _kFixedSize + i * _kLogEntrySize;
    final end = start + _kLogEntrySize;
    try {
      log.add(ActivityEntry.fromBuffer(raw.sublist(start, end)));
    } catch (e) {
      skrLogger.w('Pod log#$i decode error: $e');
    }
  }

  // 3) logIndex (if present)
  int logIndex = 0;
  final indexAbs = base + _kIndexOffset;
  if (raw.length > indexAbs) {
    logIndex = raw[indexAbs];
  }

  final map = {...decoded, 'log': log, 'logIndex': logIndex};
  return Pod.fromJson(map);
}

//Still testing. Maybe no longer needed.
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
