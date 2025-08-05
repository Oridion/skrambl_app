import 'package:flutter/foundation.dart';
import 'package:skrambl_app/services/wallet_balance_stream.dart';
import 'package:skrambl_app/services/price_service.dart';
import 'package:skrambl_app/utils/logger.dart';

class WalletBalanceProvider extends ChangeNotifier {
  final WalletBalanceStream _stream = WalletBalanceStream();

  int? _lamports;
  double _usdPrice = 0;
  bool _isLoading = true;
  String? _pubkey;
  String? get pubkey => _pubkey;

  int? get lamports => _lamports;
  double get solBalance => (_lamports ?? 0) / 1e9;
  double get usdBalance => solBalance * _usdPrice;
  bool get isLoading => _isLoading;

  Stream<int>? _balanceStream;

  void start(String pubkey) {
    if (_pubkey == pubkey) return; // prevent re-init on same key

    skrLogger.i("Starting WalletBalanceProvider for $pubkey");
    _pubkey = pubkey;
    _isLoading = true;
    notifyListeners();

    _balanceStream = _stream.start(pubkey);
    _balanceStream!.listen((lamports) async {
      final price = await fetchSolPriceUsd();
      _lamports = lamports;
      _usdPrice = price;
      _isLoading = false;
      notifyListeners();
    });
  }

  void stop() {
    _stream.stop();
    _balanceStream = null;
    _pubkey = null;
    _lamports = null;
    _isLoading = true;
    notifyListeners();
  }
}
