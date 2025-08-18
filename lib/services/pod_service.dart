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

  //return Pod.fromBuffer(rawBytes);
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
  required Commitment commitment,
}) async {
  final rpc = SolanaClientService().rpcClient;

  try {
    final accountInfo = await rpc.getAccountInfo(podPda, encoding: Encoding.base64, commitment: commitment);

    final value = accountInfo.value;
    if (value == null) {
      // account missing at this commitment
      return null;
    }

    // Safety: owner must be your program
    // TODO: Not sure if this correct. Owner the creator?
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
    if (raw.length < _kAnchorDisc + _kFixedSize) {
      skrLogger.w('Pod too small: ${raw.length}');
      return null;
    }

    // Skip Anchor discriminator
    final base = _kAnchorDisc;

    // 1) Fixed header slice [base .. base+150)
    final fixedSlice = raw.sublist(base, base + _kFixedSize);
    final decoded = Pod.shortCodec.decode(fixedSlice);

    // 2) Logs region up to 10 entries of 13 bytes each
    final remaining = raw.length - base - _kFixedSize;
    final logsAvail = remaining.clamp(0, _kLogsRegionSize);
    final entries = logsAvail ~/ _kLogEntrySize;

    final log = <ActivityEntry>[];
    for (int i = 0; i < entries; i++) {
      final start = base + _kFixedSize + i * _kLogEntrySize;
      final end = start + _kLogEntrySize;
      final entryBytes = raw.sublist(start, end);
      try {
        log.add(ActivityEntry.fromBuffer(entryBytes));
      } catch (e) {
        // keep going; treat bad entry as absent
        skrLogger.w('Pod log#$i decode error: $e');
      }
    }

    // 3) logIndex at absolute offset if present
    int logIndex = 0;
    final indexAbs = base + _kIndexOffset;
    if (raw.length > indexAbs) {
      logIndex = raw[indexAbs];
    }

    // Build model
    final map = {...decoded, 'log': log, 'logIndex': logIndex};
    return Pod.fromJson(map);
  } catch (e, st) {
    skrLogger.w('fetchPodAccount error: $e\n$st');
    return null;
  }
}
