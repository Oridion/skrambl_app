import 'dart:math';

String generatePasscode({int length = 6}) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();

  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

int generatePodId() {
  final random = Random.secure();
  return random.nextInt(65536); // Range: 0 to 65535 inclusive
}
