class SendFormModel {
  // Shared across both standard and skrambled
  String? destinationWallet;
  double? amount; // in SOL

  // Only for skrambled
  int delaySeconds = 0;
  double fee = 0;

  bool isSkrambled = false;

  void reset() {
    destinationWallet = null;
    amount = null;
    delaySeconds = 0;
    fee = 0;
    isSkrambled = false;
  }
}
