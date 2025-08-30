import 'dart:math' as math;

import 'package:skrambl_app/models/activity_model.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana_borsh/borsh.dart';
import 'package:solana_borsh/codecs.dart';
import 'package:solana_borsh/models.dart';
import 'package:solana_borsh/types.dart';

// Byte sizes of each field up to log[]
// account_type      = 1
// version           = 1
// mode              = 1
// next_process      = 1
// last_process      = 1
// is_in_transit     = 1
// id                = 2
// hops              = 2
// delay             = 4
// next_process_at   = 8
// land_at           = 8
// created_at        = 8
// last_process_at   = 8
// lamports          = 8
// location          = 32
// destination       = 32
// passcode_hash     = 32
//                   -----
// subtotal          = 150 bytes
// log               = 10 * 19 bytes = 190 bytes
// log_index         = 1 byte
// post-disc total   = 341 bytes ( + 8 anchor = 349 raw )
class Pod extends BorshObject {
  Pod({
    required this.accountType,
    required this.version,
    required this.mode,
    required this.nextProcess,
    required this.lastProcess,
    required this.isInTransit,
    required this.id,
    required this.hops,
    required this.delay,
    required this.nextProcessAt,
    required this.landAt,
    required this.createdAt,
    required this.lastProcessAt,
    required this.lamports,
    required this.location,
    required this.destination,
    required this.passcodeHash,
    required this.log,
    required this.logIndex,
  });

  final int accountType;
  final int version;
  final int mode;
  final int nextProcess;
  final int lastProcess;
  final int isInTransit;
  final int id;
  final int hops;
  final int delay;
  final int nextProcessAt;
  final int landAt;
  final int createdAt;
  final int lastProcessAt;
  final BigInt lamports;
  final List<int> location;
  final List<int> destination;
  final List<int> passcodeHash;
  final List<ActivityEntry> log;
  final int logIndex;

  static BorshSchema get staticSchema => {
    'accountType': borsh.u8,
    'version': borsh.u8,
    'mode': borsh.u8,
    'nextProcess': borsh.u8,
    'lastProcess': borsh.u8,
    'isInTransit': borsh.u8,
    'id': borsh.u16,
    'hops': borsh.u16,
    'delay': borsh.u32,
    'nextProcessAt': borsh.i64,
    'landAt': borsh.i64,
    'createdAt': borsh.i64,
    'lastProcessAt': borsh.i64,
    'lamports': borsh.u64,
    'location': borsh.array(borsh.u8, 32),
    'destination': borsh.array(borsh.u8, 32),
    'passcodeHash': borsh.array(borsh.u8, 32),
    'log': borsh.array(ActivityEntry.borshCodec, 10), // ← include logs
    'logIndex': borsh.u8,
  };

  @override
  BorshSchema get borshSchema => Pod.staticSchema;

  // 150-byte fixed header ONLY
  static final BorshStructCodec shortCodec = BorshStructCodec({
    'accountType': borsh.u8,
    'version': borsh.u8,
    'mode': borsh.u8,
    'nextProcess': borsh.u8,
    'lastProcess': borsh.u8,
    'isInTransit': borsh.u8,
    'id': borsh.u16,
    'hops': borsh.u16,
    'delay': borsh.u32,
    'nextProcessAt': borsh.i64,
    'landAt': borsh.i64,
    'createdAt': borsh.i64,
    'lastProcessAt': borsh.i64,
    'lamports': borsh.u64,
    'location': borsh.array(borsh.u8, 32),
    'destination': borsh.array(borsh.u8, 32),
    'passcodeHash': borsh.array(borsh.u8, 32),
  });

  //Full version
  static BorshStructCodec get borshCodec => BorshStructCodec({
    'accountType': borsh.u8,
    'version': borsh.u8,
    'mode': borsh.u8,
    'nextProcess': borsh.u8,
    'lastProcess': borsh.u8,
    'isInTransit': borsh.u8,
    'id': borsh.u16,
    'hops': borsh.u16,
    'delay': borsh.u32,
    'nextProcessAt': borsh.i64,
    'landAt': borsh.i64,
    'createdAt': borsh.i64,
    'lastProcessAt': borsh.i64,
    'lamports': borsh.u64,
    'location': borsh.array(borsh.u8, 32),
    'destination': borsh.array(borsh.u8, 32),
    'passcodeHash': borsh.array(borsh.u8, 32),
    'log': borsh.array(ActivityEntry.borshCodec, 10), // ← include logs
    'logIndex': borsh.u8,
  });

  @override
  factory Pod.fromJson(Map<String, dynamic> json) => Pod(
    accountType: json['accountType'],
    version: json['version'],
    mode: json['mode'],
    nextProcess: json['nextProcess'],
    lastProcess: json['lastProcess'],
    isInTransit: json['isInTransit'],
    id: json['id'],
    hops: json['hops'],
    delay: json['delay'],
    nextProcessAt: json['nextProcessAt'],
    landAt: json['landAt'],
    createdAt: json['createdAt'],
    lastProcessAt: json['lastProcessAt'],
    lamports: json['lamports'],
    location: List<int>.from(json['location']),
    destination: List<int>.from(json['destination']),
    passcodeHash: List<int>.from(json['passcodeHash']),
    log: List<ActivityEntry>.from(json['log']?.map((entry) => ActivityEntry.fromJson(entry))),
    logIndex: json['logIndex'],
  );

  @override
  Map<String, dynamic> toJson() => {
    'accountType': accountType,
    'version': version,
    'mode': mode,
    'nextProcess': nextProcess,
    'lastProcess': lastProcess,
    'isInTransit': isInTransit,
    'id': id,
    'hops': hops,
    'delay': delay,
    'nextProcessAt': nextProcessAt,
    'landAt': landAt,
    'createdAt': createdAt,
    'lastProcessAt': lastProcessAt,
    'lamports': _encBig(lamports),
    'location': location,
    'destination': destination,
    'passcodeHash': passcodeHash,
    'log': log.map((entry) => entry.toJson()).toList(),
    'logIndex': logIndex,
  };
  static String? _encBig(BigInt? v) => v?.toString();
  static const int _kFixedSize = 150;
  static const int _kLogEntrySize = 19;
  static const int _kMaxEntries = 10;
  static const int _kLogsRegionSize = _kLogEntrySize * _kMaxEntries; // 190
  static const int _kIndexOffset = _kFixedSize + _kLogsRegionSize; // 340
  static const int _kMinTotal = _kFixedSize + _kLogsRegionSize + 1; // 341 (no padding)

  /// Accepts RAW account buffer (includes 8-byte Anchor discriminator).
  static Pod? fromAccountData(List<int> raw, {String debugLabel = '', bool swallowErrors = true}) {
    try {
      //skrLogger.i('Pod.decode[$debugLabel] rawLen=${raw.length}');
      if (raw.length < 8 + _kMinTotal) {
        skrLogger.w(
          'Pod.decode[$debugLabel] too small for (disc+struct): have=${raw.length}, need>=${8 + _kMinTotal}',
        );
        return null;
      }
      final sliced = raw.sublist(8); // skip anchor discriminator once
      //skrLogger.i('Pod.decode[$debugLabel] slicedLen=${sliced.length}');
      return fromBuffer(sliced, debugLabel: debugLabel, swallowErrors: swallowErrors);
    } catch (e, st) {
      skrLogger.e('Pod.decode[$debugLabel] fromAccountData exception: $e\n$st');
      if (!swallowErrors) rethrow;
      return null;
    }
  }

  /// Expects data that ALREADY skipped the 8-byte Anchor discriminator.
  static Pod? fromBuffer(List<int> data, {String debugLabel = '', bool swallowErrors = true}) {
    // Local helper: safe sublist with logging instead of throwing
    List<int> safeSublist(List<int> src, int start, int end) {
      final total = src.length;
      if (start < 0 || end < 0 || start > end) {
        skrLogger.e('Pod.decode[$debugLabel] safeSublist invalid range: [$start, $end)');
        return const <int>[];
      }
      if (end > total) {
        skrLogger.w(
          'Pod.decode[$debugLabel] safeSublist truncated: '
          'requested [$start, $end) > total=$total; clamping.',
        );
        end = total;
        if (start >= end) return const <int>[];
      }
      return src.sublist(start, end);
    }

    try {
      final int totalLen = data.length; // post-disc length expected
      // skrLogger.i('┌─ Pod.decode[$debugLabel]');
      // skrLogger.i(
      //   '│ totalLen(post-disc)=$totalLen  '
      //   '(need ≥ $_kMinTotal = $_kFixedSize + $_kLogsRegionSize + 1)',
      // );

      if (totalLen < _kMinTotal) {
        skrLogger.w('│ too small post-disc: have=$totalLen, need≥$_kMinTotal → abort');
        skrLogger.i('└─ Pod.decode[$debugLabel] END (too small)');
        return null;
      }

      // 1) Fixed header decode (0..150)
      //skrLogger.i('│ header: bytes [0..$_kFixedSize) len=$_kFixedSize');
      final fixedPart = safeSublist(data, 0, _kFixedSize);
      if (fixedPart.length != _kFixedSize) {
        skrLogger.w('│ header slice shorter than expected: ${fixedPart.length}');
      }
      Map<String, dynamic> fixed;
      try {
        fixed = shortCodec.decode(fixedPart);
        // skrLogger.i(
        //   '│ header decode OK: '
        //   'version=${fixed['version']} lastProcess=${fixed['lastProcess']} delay=${fixed['delay']}',
        // );
      } catch (e) {
        skrLogger.e('│ header decode ERROR: $e');
        skrLogger.i('└─ Pod.decode[$debugLabel] END (header decode failed)');
        return null;
      }

      // 2) Logs region: compute available and entry size
      // We expect a reserved region for logs of size _kLogsRegionSize and 1 trailing byte for logIndex.
      final int reservedLogs = _kLogsRegionSize; // typical max region size
      final int tailBytes = 1; // logIndex byte
      final int logsAvailRaw = (totalLen - _kFixedSize - tailBytes);
      // If account is longer than min, cap to reserved region so we don’t read beyond.
      final int logsAvail = math.min(math.max(logsAvailRaw, 0), reservedLogs);

      // Decide entry size: prefer 19, else 13 when it divides cleanly. Probe if ambiguous.
      int entrySize = 19;
      if (logsAvail % 19 == 0 && logsAvail != 0) {
        entrySize = 19;
      } else if (logsAvail % 13 == 0 && logsAvail != 0) {
        entrySize = 13;
      } else {
        final canRead19 = totalLen >= (_kFixedSize + 19);
        final canRead13 = totalLen >= (_kFixedSize + 13);
        entrySize = canRead19 ? 19 : (canRead13 ? 13 : 19);
      }

      final int maxEntriesPossible = (logsAvail ~/ entrySize);
      final int entriesToRead = math.min(_kMaxEntries, maxEntriesPossible);

      // skrLogger.i(
      //   '│ logs: totalLen=$totalLen  hdr=$_kFixedSize  tail=$tailBytes  '
      //   'logsAvailRaw=$logsAvailRaw  logsAvail=$logsAvail  '
      //   'entrySize=$entrySize  entriesToRead=$entriesToRead',
      // );

      // 2a) Decode logs one by one with safe slicing
      final logs = <ActivityEntry>[];
      for (int i = 0; i < entriesToRead; i++) {
        final start = _kFixedSize + i * entrySize;
        final end = start + entrySize;
        final slice = safeSublist(data, start, end);
        //skrLogger.i('│   log#$i slice=[$start,$end) actualLen=${slice.length}');
        if (slice.length != entrySize) {
          skrLogger.w('│   log#$i slice length mismatch: expected=$entrySize got=${slice.length}');
        }

        try {
          logs.add(ActivityEntry.fromBuffer(slice));
          //skrLogger.i('│   log#$i decode OK');
        } catch (e) {
          skrLogger.w('│   log#$i decode ERROR: $e');
        }
      }

      // 3) Read logIndex after the reserved log region (fixed position by spec)
      final int indexPos =
          _kIndexOffset; // = _kFixedSize + (_kLogEntrySize * _kMaxEntries) if constants match
      int logIndex = 0;
      if (totalLen > indexPos) {
        logIndex = data[indexPos];
        if (logIndex < 0 || logIndex >= _kMaxEntries) {
          skrLogger.w('│ logIndex out of range @ $indexPos: $logIndex (max=$_kMaxEntries); clamping');
          logIndex = logIndex % _kMaxEntries;
        }
        skrLogger.i('│ logIndex=$logIndex @ byte $indexPos');
      } else {
        skrLogger.w('│ no logIndex byte: totalLen=$totalLen ≤ indexPos=$indexPos');
      }

      // 4) Build Pod object
      final pod = Pod(
        accountType: fixed['accountType'],
        version: fixed['version'],
        mode: fixed['mode'],
        nextProcess: fixed['nextProcess'],
        lastProcess: fixed['lastProcess'],
        isInTransit: fixed['isInTransit'],
        id: fixed['id'],
        hops: fixed['hops'],
        delay: fixed['delay'],
        nextProcessAt: fixed['nextProcessAt'],
        landAt: fixed['landAt'],
        createdAt: fixed['createdAt'],
        lastProcessAt: fixed['lastProcessAt'],
        lamports: fixed['lamports'],
        location: List<int>.from(fixed['location']),
        destination: List<int>.from(fixed['destination']),
        passcodeHash: List<int>.from(fixed['passcodeHash']),
        log: logs,
        logIndex: logIndex,
      );

      //skrLogger.i('│ success: entries=${logs.length}, lastProcess=${pod.lastProcess}, mode=${pod.mode}');
      //skrLogger.i('└─ Pod.decode[$debugLabel] END');
      return pod;
    } catch (e, st) {
      skrLogger.e('│ Pod.decode[$debugLabel] EXCEPTION: $e\n$st');
      skrLogger.i('└─ Pod.decode[$debugLabel] END (exception)');
      if (!swallowErrors) rethrow;
      return null;
    }
  }
}
