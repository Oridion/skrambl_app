import 'dart:math';

import 'package:solana/solana.dart';

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
      return 'Instant';
    case 1:
      return 'Delay';
    case 5:
      return 'Standard';
    default:
      return 'Mode $mode';
  }
}
