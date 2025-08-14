import 'dart:async';
import 'package:flutter/foundation.dart';

class MinuteTicker extends ChangeNotifier {
  Timer? _t;

  MinuteTicker() {
    _start();
  }

  void _start() {
    // align to minute boundary
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    Future.delayed(next.difference(now), () {
      if (_t != null) return; // already started
      notifyListeners(); // first tick on boundary
      _t = Timer.periodic(const Duration(minutes: 1), (_) => notifyListeners());
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }
}
