import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:skrambl_app/models/land_book_model.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:solana/dto.dart';
//import 'package:solana/solana.dart';

import '../../utils/logger.dart';

Future<LandBook?> fetchLandBook() async {
  final rpc = SolanaClientService().rpcClient;
  const landBookPKString = '7tuxkiCx6iS6QAtymhaptbug9GX8g9fy27huZjUCtmji';

  try {
    // You can add commitment if your RpcClient supports it
    final accountInfo = await rpc.getAccountInfo(landBookPKString, encoding: Encoding.base64);

    final value = accountInfo.value;
    if (value == null) {
      skrLogger.e('Land book account not found.');
      return null;
    }

    final data = value.data;
    if (data is! BinaryAccountData) {
      skrLogger.e('Unexpected data format for land book account');
      return null;
    }

    // Full raw account (includes 8-byte Anchor discriminator)
    final rawBytes = Uint8List.fromList(data.data);

    // Parse with your LandBook helper (it skips the discriminator internally)
    final book = LandBook.fromAccountData(rawBytes);

    skrLogger.i('LandBook fetched: ${book.tickets.length} ticket(s)');
    return book;
  } catch (e, st) {
    skrLogger.e('⛔ Error fetching LandBook: $e');
    skrLogger.e(st);
    return null;
  }
}

bool landBookHasTicket(LandBook book, Uint8List ticket16) {
  return book.containsTicket(ticket16);
}

// ----- GENERATE TICKET ------- //

Uint8List _u16le(int v) {
  final b = ByteData(2)..setUint16(0, v, Endian.little);
  return b.buffer.asUint8List();
}

Uint8List _i64le(int v) {
  final b = ByteData(8)..setInt64(0, v, Endian.little);
  return b.buffer.asUint8List();
}

Uint8List _u64leBig(BigInt v) {
  var x = v.toUnsigned(64);
  final out = Uint8List(8);
  for (var i = 0; i < 8; i++) {
    out[i] = (x & BigInt.from(0xff)).toInt();
    x >>= 8;
  }
  return out;
}

/// Dart equivalent of Rust `token_from`
/// digest = SHA256("ORIDION_LAND_V1" || id_le || dest(32) || amount_le || created_at_le)[0..16]
Uint8List generateTicket({
  required int id, // u16
  required List<int> dest, // 32-byte pubkey from Pod (raw bytes)
  required BigInt amount, // u64
  required int createdAt, // i64 (unix seconds)
}) {
  if (dest.length != 32) {
    throw ArgumentError('dest must be 32 bytes, got ${dest.length}');
  }

  final builder = BytesBuilder()
    ..add(utf8.encode('ORIDION_LAND_V1'))
    ..add(_u16le(id))
    ..add(Uint8List.fromList(dest))
    ..add(_u64leBig(amount))
    ..add(_i64le(createdAt));

  final digest = sha256.convert(builder.toBytes()).bytes;
  return Uint8List.fromList(digest.sublist(0, 16));
}

//Get land book pda
// Future<Ed25519HDPublicKey> findLandBookPda(Ed25519HDPublicKey programId) async {
//   final seed = [utf8.encode('land_book')]; // b"land_book"
//   final res = await Ed25519HDPublicKey.findProgramAddress(seeds: seed, programId: programId);
//   return res;
// }
