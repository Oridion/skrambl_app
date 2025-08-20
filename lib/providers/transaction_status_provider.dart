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
  String? _activePodId;
  TransactionPhase _phase = TransactionPhase.sending;
  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  final Duration minDwell = const Duration(milliseconds: 200);

  String? get activePodId => _activePodId;
  TransactionPhase get phase => _phase;

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

  void setActivePod(String podId, {bool resetPhase = true}) {
    _activePodId = podId;
    if (resetPhase) {
      _phase = TransactionPhase.sending;
      _lastUpdate = DateTime.now();
    }
    notifyListeners();
  }

  void clearActivePod(String podId) {
    if (_activePodId == podId) {
      _activePodId = null;
      notifyListeners();
    }
  }

  void setPhase(TransactionPhase p) {
    _phase = p;
    _lastUpdate = DateTime.now();
    notifyListeners();
  }

  // Use this from the watcher/manager (filters & adds tiny dwell for visibility)
  Future<void> onPhaseFromWatcher(String podId, TransactionPhase p) async {
    if (_activePodId != podId) return; // ignore other pods
    final elapsed = DateTime.now().difference(_lastUpdate);
    if (elapsed < minDwell) await Future.delayed(minDwell - elapsed);
    if (_activePodId != podId) return; // user may have switched screens
    _phase = p;
    _lastUpdate = DateTime.now();
    notifyListeners();
  }
}
