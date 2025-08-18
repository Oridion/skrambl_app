class SendRoutes {
  static const type = '/';
  static const destination = '/destination';

  //Skrambled routes
  static const skAmount = '/sk/amount';
  static const skSummary = '/sk/summary';

  //Standard routes
  static const stAmount = '/st/amount';
  static const stSummary = '/st/summary';
}

String titleFor(String? routeName) {
  switch (routeName) {
    case SendRoutes.type:
      return 'Send type';
    case SendRoutes.destination:
      return 'Select Destination';
    case SendRoutes.skAmount:
      return 'Amount & Delay';
    case SendRoutes.skSummary:
      return 'Summary';
    case SendRoutes.stAmount:
      return 'Amount';
    case SendRoutes.stSummary:
      return 'Summary';
    default:
      return 'Send';
  }
}
