import 'dart:typed_data';

import 'package:solana_borsh/borsh.dart';
import 'package:solana_borsh/codecs.dart';
import 'package:solana_borsh/models.dart';
import 'package:solana_borsh/types.dart';

// Example of usage
// final acct = await rpc.getAccountInfo(landBookPda);
// final raw = base64Decode((acct.value!.data as List).first as String);
// final book = LandBook.fromAccountData(raw);
// final present = book.containsTicket(myTicket16);

class LandBook extends BorshObject {
  LandBook({required this.tickets});

  /// Each ticket is exactly 16 bytes.
  final List<Uint8List> tickets;

  // vec<[u8;16]>
  static final _vec16 = borsh.vec(borsh.array(borsh.u8, 16));

  static BorshSchema get staticSchema => {'tickets': _vec16};

  @override
  BorshSchema get borshSchema => staticSchema;

  /// Full struct codec: { tickets: vec<[u8;16]> }
  static final BorshStructCodec _codec = BorshStructCodec({'tickets': _vec16});

  /// Decode from full account data that includes the 8-byte Anchor discriminator.
  factory LandBook.fromAccountData(Uint8List raw) {
    final sliced = raw.length >= 8 ? raw.sublist(8) : raw;
    final map = _codec.decode(sliced);
    final list = (map['tickets'] as List).cast<List<int>>().map((e) => Uint8List.fromList(e)).toList();
    return LandBook(tickets: list);
  }

  /// Decode from bytes that ALREADY skipped the 8-byte discriminator.
  factory LandBook.fromBuffer(Uint8List data) {
    final map = _codec.decode(data);
    final list = (map['tickets'] as List).cast<List<int>>().map((e) => Uint8List.fromList(e)).toList();
    return LandBook(tickets: list);
  }

  /// Check presence of a specific 16-byte ticket.
  bool containsTicket(Uint8List needle) {
    if (needle.length != 16) return false;
    for (final t in tickets) {
      if (t.length != 16) continue;
      var eq = true;
      for (var i = 0; i < 16; i++) {
        if (t[i] != needle[i]) {
          eq = false;
          break;
        }
      }
      if (eq) return true;
    }
    return false;
  }

  /// (Optional) JSON helpers — represent tickets as base64/hex if you prefer.
  @override
  factory LandBook.fromJson(Map<String, dynamic> json) => LandBook(
    tickets: (json['tickets'] as List<dynamic>)
        .map((e) => Uint8List.fromList(List<int>.from(e as List)))
        .toList(),
  );

  @override
  Map<String, dynamic> toJson() => {'tickets': tickets.map((t) => t.toList()).toList()};
}
