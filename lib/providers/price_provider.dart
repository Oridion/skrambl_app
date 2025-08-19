import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skrambl_app/services/price_service.dart';

class PriceProvider extends ChangeNotifier {
  double _solUsd = 0;
  Timer? _t;

  PriceProvider() {
    _tick();
    _t = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  double get solUsd => _solUsd;

  Future<void> _tick() async {
    final v = await fetchSolPriceUsd(); // your defensive function
    if (v != _solUsd) {
      _solUsd = v;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }
}
