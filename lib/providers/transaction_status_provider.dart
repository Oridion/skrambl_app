import 'package:flutter/material.dart';

enum TransactionPhase {
  sending, // Got txSig but not confirmed yet
  confirming, // Waiting for finalization
  scrambling, // Calling API to queue
  delivering,
  completed, // Done!
  failed, // Error happened
}

class TransactionStatusProvider extends ChangeNotifier {
  TransactionPhase _phase = TransactionPhase.sending;
  TransactionPhase get phase => _phase;

  void setPhase(TransactionPhase phase) {
    _phase = phase;
    notifyListeners();
  }

  String get displayText {
    switch (_phase) {
      case TransactionPhase.sending:
        return "SENDING";
      case TransactionPhase.confirming:
        return "CONFIRMING";
      case TransactionPhase.scrambling:
        return "SKRAMBLING";
      case TransactionPhase.delivering:
        return "DELIVERING";
      case TransactionPhase.completed:
        return "COMPLETED";
      case TransactionPhase.failed:
        return "FAILED";
    }
  }
}
