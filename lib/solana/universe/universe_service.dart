import 'dart:typed_data';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana/dto.dart';
import 'package:solana_borsh/borsh.dart';
import '../../models/universe_model.dart';

Future<Universe?> fetchUniverseAccount() async {
  final rpc = SolanaClientService().rpcClient;
  const universePda = '5QLGUF38PzfKkvPdAaMKYEnyjNZ3xsTJDxPJ3ZyK3L4Z';

  try {
    final accountInfo = await rpc.getAccountInfo(universePda, encoding: Encoding.base64);

    final value = accountInfo.value;
    if (value == null) {
      skrLogger.e('Universe account not found.');
      return null;
    }

    final data = value.data;
    if (data is! BinaryAccountData) {
      skrLogger.e('Unexpected data format for universe account');
      return null;
    }

    final rawBytes = Uint8List.fromList(data.data);
    final sliced = rawBytes.sublist(8);

    // skrLogger.i(
    //   '🧬 Raw Universe Bytes: ${sliced.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    // );

    final universe = borsh.deserialize(Universe.staticSchema, sliced, Universe.fromJson);

    // skrLogger.i('Universe account fetched successfully');
    // Log all fields
    // skrLogger.i('Universe Decoded:');
    // skrLogger.i('  accountType   : ${universe.accountType}');
    // skrLogger.i('  locked        : ${universe.locked}');
    // skrLogger.i('  bump          : ${universe.bump}');
    // skrLogger.i('  created       : ${universe.created}');
    // skrLogger.i('  lastUpdated   : ${universe.lastUpdated}');
    // skrLogger.i('  fee           : ${universe.fee} (lamports)');
    // skrLogger.i('  increment     : ${universe.increment} (lamports)');

    return universe;
  } catch (e, st) {
    skrLogger.e('⛔ Error fetching universe account: $e');
    skrLogger.e(st);
    return null;
  }
}
