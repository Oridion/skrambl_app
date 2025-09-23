import 'dart:typed_data';
import 'package:convert/convert.dart';
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
// authority         = 32
//                   -----
// subtotal (struct) = 174 bytes
// +8 anchor disc    = 182 bytes total
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
    required this.authority,
  });

  // 1-byte fields
  final int accountType; // u8
  final int version; // u8
  final int mode; // u8
  final int nextProcess; // u8
  final int lastProcess; // u8
  final int isInTransit; // u8

  // 2-byte
  final int id; // u16
  final int hops; // u16

  // 4-byte
  final int delay; // u32

  // 8-byte
  final int nextProcessAt; // i64
  final int landAt; // i64
  final int createdAt; // i64
  final int lastProcessAt; // i64
  final BigInt lamports; // u64

  // 32-byte
  final List<int> location; // [u8; 32] Pubkey
  final List<int> destination; // [u8; 32]
  final List<int> passcodeHash; // [u8; 32]
  final List<int> authority; // [u8; 32]

  // --- constants
  static const int structSize = 182; // actual fields
  static const int paddedStructSize = 184; // aligned struct
  static const int accountSize = 192; // padded + disc

  // --- schema
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
    'authority': borsh.array(borsh.u8, 32),
  };

  @override
  BorshSchema get borshSchema => Pod.staticSchema;

  // 174-byte fixed header ONLY (no logs)
  static final BorshStructCodec structCodec = BorshStructCodec(staticSchema);

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
    'authority': borsh.array(borsh.u8, 32),
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
    authority: List<int>.from(json['authority']),
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
    'authority': authority,
  };
  static String? _encBig(BigInt? v) => v?.toString();

  /// Accepts RAW account buffer (includes 8-byte Anchor discriminator).
  // --- decoding
  static Pod? fromAccountData(List<int> raw, {String debugLabel = '', bool swallowErrors = true}) {
    try {
      final totalLen = raw.length;
      skrLogger.i('┌─ Pod.decode[$debugLabel] fromAccountData');
      skrLogger.i('│ rawLen=$totalLen (accountSize=$accountSize, includes 8-byte disc)');

      if (totalLen < 8) {
        skrLogger.w('│ too small: rawLen=$totalLen < 8 (no room for discriminator)');
        skrLogger.i('└─ Pod.decode[$debugLabel] END (too small)');
        return null;
      }

      if (totalLen < accountSize) {
        skrLogger.w(
          '│ shorter than padded accountSize=$accountSize; '
          'continuing with len=$totalLen (RPC may trim padding)',
        );
      }

      // --- Skip 8-byte discriminator
      final sliced = raw.sublist(8);
      skrLogger.i('│ slicedLen=${sliced.length} (rawLen=$totalLen - disc=8)');

      // --- Decode using fromBuffer
      final pod = fromBuffer(sliced, debugLabel: debugLabel, swallowErrors: swallowErrors);

      if (pod == null) {
        skrLogger.w('│ fromBuffer → null');
      } else {
        skrLogger.i(
          '│ fromBuffer OK → '
          'version=${pod.version}, mode=${pod.mode}, lastProcess=${pod.lastProcess}',
        );
      }

      skrLogger.i('└─ Pod.decode[$debugLabel] END');
      return pod;
    } catch (e, st) {
      skrLogger.e('│ Pod.decode[$debugLabel] EXCEPTION: $e\n$st');
      skrLogger.i('└─ Pod.decode[$debugLabel] END (exception)');
      if (!swallowErrors) rethrow;
      return null;
    }
  }

  /// Expects data that ALREADY skipped the 8-byte Anchor discriminator.
  static Pod? fromBuffer(List<int> data, {String debugLabel = '', bool swallowErrors = true}) {
    try {
      final totalLen = data.length;
      skrLogger.i('┌─ Pod.decode[$debugLabel]');
      skrLogger.i('│ post-disc length=$totalLen (structSize=$structSize, padded=$paddedStructSize)');

      if (totalLen < structSize) {
        skrLogger.w('│ too small post-disc: have=$totalLen, need≥$structSize');
        skrLogger.i('└─ Pod.decode[$debugLabel] END (too small)');
        return null;
      }

      // Slice the full padded region (Anchor struct size)
      final sliceLen = (totalLen >= paddedStructSize) ? paddedStructSize : structSize;
      skrLogger.i('│ decoding slice [0..$sliceLen) out of total=$totalLen');

      final fixed = structCodec.decode(data.sublist(0, sliceLen));

      skrLogger.i(
        '│ decode OK → version=${fixed['version']} '
        'mode=${fixed['mode']} lastProcess=${fixed['lastProcess']} '
        'lamports=${fixed['lamports']}',
      );
      skrLogger.i('└─ Pod.decode[$debugLabel] END (success)');

      return Pod(
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
        authority: List<int>.from(fixed['authority']),
      );
    } catch (e, st) {
      skrLogger.e('│ Pod.decode[$debugLabel] EXCEPTION: $e\n$st');
      skrLogger.i('└─ Pod.decode[$debugLabel] END (exception)');
      if (!swallowErrors) rethrow;
      return null;
    }
  }
}

extension PodTicket on Pod {
  /// 16-byte ticket stored in the first half of `passcodeHash`.
  /// Returns null if not set (all zeros or too short).
  Uint8List? get ticketBytes16 {
    if (passcodeHash.length < 16) return null;
    final t = Uint8List.fromList(passcodeHash.sublist(0, 16));
    final isAllZero = t.every((b) => b == 0);
    return isAllZero ? null : t;
  }

  /// Hex string of the ticket, or null if not set.
  String? get ticketHex => ticketBytes16 == null ? null : hex.encode(ticketBytes16!);
}
