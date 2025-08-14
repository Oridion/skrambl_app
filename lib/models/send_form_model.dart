class SendFormModel {
  // Shared across both standard and skrambled
  String? destinationWallet;
  double? amount; // in SOL
  String? usdAmount; // USD equivalent, if applicable
  double? solUsdPrice; // Optional SOL price in USD for display

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
