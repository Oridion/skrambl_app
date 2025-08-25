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
  static const int _kLogEntrySize = 19; //  ← updated
  static const int _kMaxEntries = 10;
  static const int _kLogsRegionSize = _kLogEntrySize * _kMaxEntries; // 190
  static const int _kIndexOffset = _kFixedSize + _kLogsRegionSize; // 340
  static const int _kMinTotal = _kFixedSize + _kLogsRegionSize + 1; // 341 (no padding)

  /// Accepts RAW account buffer (includes 8-byte Anchor discriminator).
  static Pod? fromAccountData(List<int> raw, {String debugLabel = '', bool swallowErrors = true}) {
    try {
      skrLogger.i('Pod.decode[$debugLabel] rawLen=${raw.length}');
      if (raw.length < 8 + _kMinTotal) {
        skrLogger.w(
          'Pod.decode[$debugLabel] too small for (disc+struct): have=${raw.length}, need>=${8 + _kMinTotal}',
        );
        return null;
      }
      final sliced = raw.sublist(8); // skip anchor discriminator once
      skrLogger.i('Pod.decode[$debugLabel] slicedLen=${sliced.length}');
      return fromBuffer(sliced, debugLabel: debugLabel, swallowErrors: swallowErrors);
    } catch (e, st) {
      skrLogger.e('Pod.decode[$debugLabel] fromAccountData exception: $e\n$st');
      if (!swallowErrors) rethrow;
      return null;
    }
  }

  /// Expects data that ALREADY skipped the 8-byte Anchor discriminator.
  static Pod? fromBuffer(
    List<int> data, {
    String debugLabel = '',
    bool swallowErrors = true, // ← add this
  }) {
    try {
      final int totalLen = data.length;
      skrLogger.i('Pod.decode[$debugLabel] postDiscLen=$totalLen');

      if (totalLen < _kMinTotal) {
        skrLogger.w('Pod.decode[$debugLabel] too small post-disc: have=$totalLen, need>=$_kMinTotal');
        return null;
      }

      // 1) Decode the 150-byte fixed header with shortCodec
      skrLogger.i('💡 Pod.decode[$debugLabel] fixed[0..$_kFixedSize) start');
      final fixedPart = data.sublist(0, _kFixedSize);
      final fixed = shortCodec.decode(fixedPart); // Map<String, dynamic>
      skrLogger.i(
        '💡 Pod.decode[$debugLabel] fixed ok: '
        'version=${fixed['version']}, lastProcess=${fixed['lastProcess']}, delay=${fixed['delay']}',
      );

      // 2) Decode up to 10 log entries (each 19 bytes)
      final int logsAvail = math.min(totalLen - _kFixedSize, _kLogsRegionSize);
      final int availableEntries = logsAvail ~/ _kLogEntrySize;
      skrLogger.i('Pod.decode[$debugLabel] logsAvail=$logsAvail, entries=$availableEntries');

      final logs = <ActivityEntry>[];
      for (int i = 0; i < availableEntries; i++) {
        final start = _kFixedSize + i * _kLogEntrySize;
        final end = start + _kLogEntrySize; // ≤ 340
        final slice = data.sublist(start, end);
        if (slice.length != _kLogEntrySize) {
          skrLogger.w('Pod.decode[$debugLabel] log#$i size=${slice.length} expected=$_kLogEntrySize');
        }
        try {
          logs.add(ActivityEntry.fromBuffer(slice)); // expects 19 bytes
        } catch (e) {
          skrLogger.w('Pod.decode[$debugLabel] log#$i decode error: $e');
        }
      }

      // 3) logIndex at absolute offset 340 (if present)
      int logIndex = 0;
      if (totalLen > _kIndexOffset) {
        logIndex = data[_kIndexOffset];
        skrLogger.i('💡 Pod.decode[$debugLabel] logIndex=$logIndex @$_kIndexOffset');
      } else {
        skrLogger.i(
          '💡 Pod.decode[$debugLabel] no logIndex; totalLen=$totalLen <= indexOffset=$_kIndexOffset',
        );
      }

      // Build the Pod DIRECTLY (do NOT call Pod.fromJson here)
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
        lamports: fixed['lamports'], // Borsh u64 -> BigInt already
        location: List<int>.from(fixed['location']),
        destination: List<int>.from(fixed['destination']),
        passcodeHash: List<int>.from(fixed['passcodeHash']),
        log: logs, // <-- use the decoded ActivityEntry list
        logIndex: logIndex,
      );

      skrLogger.i('Pod.decode[$debugLabel] success: entries=${logs.length}, lastProcess=${pod.lastProcess}');
      return pod;
    } catch (e, st) {
      skrLogger.e('⛔ Pod.decode[$debugLabel] exception: $e\n$st');
      return null;
    }
  }
}
  // static Pod fromBuffer(List<int> data) {
  //   if (data.length < 277) {
  //     throw Exception('Invalid Pod buffer length: ${data.length}');
  //   }
  //   final fixedPart = data.sublist(0, 146);
  //   final decoded = borshCodec.decode(fixedPart);

  //   // Manually decode log
  //   final log = <ActivityEntry>[];
  //   final logStart = 146;
  //   for (int i = 0; i < 10; i++) {
  //     final start = logStart + (i * 13);
  //     final end = start + 13;
  //     final entryBytes = data.sublist(start, end);
  //     log.add(ActivityEntry.fromBuffer(entryBytes));
  //   }

  //   // log_index is the last byte
  //   final logIndex = data[146 + 130];

  //   decoded['log'] = log;
  //   decoded['logIndex'] = logIndex;

  //   return Pod.fromJson(decoded);
  // }

