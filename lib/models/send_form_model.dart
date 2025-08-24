class SendFormModel {
  // Shared across both standard and skrambled
  String? userWallet;

  int? userBurnerIndex; // null = primary; set when using a burner
  bool get isFromBurner => userBurnerIndex != null;

  String? destinationWallet;
  bool isDestinationBurner = false;

  double? amount; // in SOL
  String? usdAmount; // USD equivalent, if applicable
  double? solUsdPrice; // Optional SOL price in USD for display

  // Store to show if failure.
  String? passcode;

  // Only for skrambled
  int delaySeconds = 0;
  double fee = 0;

  bool get isDelayed => delaySeconds > 0;

  bool isSkrambled = false;

  void reset() {
    userBurnerIndex = null;
    userWallet = null;
    destinationWallet = null;
    amount = null;
    usdAmount = '0';
    delaySeconds = 0;
    fee = 0;
    isSkrambled = false;
    passcode = null;
  }

  @override
  String toString() {
    return '''
    SendFormModel(
      userBurnerIndex: $userBurnerIndex,
      userWallet: $userWallet,
      destinationWallet: $destinationWallet,
      isDestinationBurner: $isDestinationBurner,
      amount: $amount,
      usdAmount: $usdAmount,
      solUsdPrice: $solUsdPrice,
      delaySeconds: $delaySeconds,
      fee: $fee,
      isSkrambled: $isSkrambled
    )''';
  }
}
