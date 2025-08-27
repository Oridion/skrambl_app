import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:skrambl_app/solana/send_skrambled_transaction.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:solana/solana.dart';

Future<Uint8List> setBlockHashOnUnsigneMessage(String unsignedBase64Tx) async {
  var txBytes = base64Decode(unsignedBase64Tx);
  return await updateBlockhashInMessage(txBytes);
}

String generatePasscode({int length = 6}) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();

  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

int generatePodId() {
  final random = Random.secure();
  return random.nextInt(1 << 16); // Range: 0 to 65535 inclusive
}

bool isSolanaAddress(String address) {
  if (address.isEmpty) return false;
  try {
    Ed25519HDPublicKey.fromBase58(address);
    return true;
  } catch (_) {
    return false;
  }
}

String modeLabel(int mode) {
  // 0=Instant, 1=Delay, extend if you add more modes
  switch (mode) {
    case 0:
      return 'SKRAMBLED';
    case 1:
      return 'SKRAMBLED';
    case 5:
      return 'STANDARD';
    default:
      return 'Mode $mode';
  }
}

String delayLabel(int delay) {
  switch (delay) {
    case 0:
      return 'INSTANT';
    default:
      return formatDelay(delay);
  }
}
