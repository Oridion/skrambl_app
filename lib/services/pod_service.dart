import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/constants/program_id.dart';
import 'package:skrambl_app/models/pod_model.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:solana/dto.dart';
import 'package:skrambl_app/utils/logger.dart';

/// Layout constants
const int _kAnchorDisc = 8;
const int _kPaddedStructSize = 184; // after 8-byte alignment
const int _kAccountSize = _kAnchorDisc + _kPaddedStructSize; // 192

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
    if (value == null) {
      return null; // account missing
    }

    if (value.owner != programId) {
      skrLogger.w('Pod owner mismatch (got ${value.owner}), skipping decode');
      return null;
    }

    final data = value.data;
    if (data is! BinaryAccountData) {
      skrLogger.w('Unexpected data format for pod account');
      return null;
    }

    final raw = Uint8List.fromList(data.data); // includes discriminator
    return _parsePodFromBytes(raw);
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

/// Internal: decode from raw bytes (skips discriminator)
Pod? _parsePodFromBytes(Uint8List raw) {
  if (raw.length < _kAccountSize) {
    skrLogger.w('Pod too small: ${raw.length}, need ≥ $_kAccountSize');
    return null;
  }

  final base = _kAnchorDisc;
  final fixedSlice = raw.sublist(base, base + _kPaddedStructSize);

  skrLogger.i(
    'Pod.decode: rawLen=${raw.length}, '
    'expect≥$_kAccountSize, slice=[${base}..${base + _kPaddedStructSize})',
  );

  try {
    final decoded = Pod.structCodec.decode(fixedSlice);
    return Pod(
      accountType: decoded['accountType'],
      version: decoded['version'],
      mode: decoded['mode'],
      nextProcess: decoded['nextProcess'],
      lastProcess: decoded['lastProcess'],
      isInTransit: decoded['isInTransit'],
      id: decoded['id'],
      hops: decoded['hops'],
      delay: decoded['delay'],
      nextProcessAt: decoded['nextProcessAt'],
      landAt: decoded['landAt'],
      createdAt: decoded['createdAt'],
      lastProcessAt: decoded['lastProcessAt'],
      lamports: BigInt.from(decoded['lamports']),
      location: List<int>.from(decoded['location']),
      destination: List<int>.from(decoded['destination']),
      passcodeHash: List<int>.from(decoded['passcodeHash']),
      authority: List<int>.from(decoded['authority']),
    );
  } catch (e) {
    skrLogger.e('Pod decode error: $e');
    return null;
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
