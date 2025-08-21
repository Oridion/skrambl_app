import 'package:flutter/material.dart';
import 'package:skrambl_app/services/network_fee_service.dart';

class NetworkFeeProvider extends ChangeNotifier {
  final NetworkFeeService _svc;
  NetworkFeeProvider(this._svc);

  int _fee = 5000;
  bool _loading = false;
  String? _error;

  int get fee => _fee;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _fee = await _svc.fetchFee();
    } catch (e) {
      _error = e.toString();
      // keep old _fee as cache
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
