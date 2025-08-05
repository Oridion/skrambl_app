import 'dart:convert';
import 'dart:typed_data';
import 'package:skrambl_app/constants/program_id.dart';
import 'package:solana/solana.dart';

Future<Ed25519HDPublicKey> getPodPDA({
  required int id,
  required Ed25519HDPublicKey creator,
}) async {
  // Convert id (u16 LE) to 2-byte buffer
  final idBytes = ByteData(2)..setUint16(0, id, Endian.little);
  final seed1 = utf8.encode('pod'); // same as Buffer.from("pod")
  final seed2 = creator.bytes;
  final seed3 = idBytes.buffer.asUint8List();
  final seeds = [seed1, seed2, seed3];
  final pda = await Ed25519HDPublicKey.findProgramAddress(
    seeds: seeds,
    programId: programPubkey,
  );
  return pda;
}
