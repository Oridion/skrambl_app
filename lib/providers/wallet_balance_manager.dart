import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/services/wallet_balance_stream.dart';

class WalletBalanceProvider extends ChangeNotifier {
  WalletBalanceProvider(PriceProvider priceProvider) {
    _attachPriceProvider(priceProvider);
  }

  final WalletBalanceStream _stream = WalletBalanceStream();

  PriceProvider? _priceProvider;
  late VoidCallback _priceListener;

  String? _pubkey;
  int? _lamports;
  bool _isLoading = true;
  StreamSubscription<int>? _sub;

  String? get pubkey => _pubkey;
  int? get lamports => _lamports;
  double get solBalance => (_lamports ?? 0) / 1e9;
  double get usdBalance => solBalance * (_priceProvider?.solUsd ?? 0);
  bool get isLoading => _isLoading;

  // Exposed for ProxyProvider.update
  void attachPriceProvider(PriceProvider priceProvider) {
    _attachPriceProvider(priceProvider);
    notifyListeners(); // safe: we're inside the notifier
  }

  void _attachPriceProvider(PriceProvider priceProvider) {
    // detach old
    if (_priceProvider != null) {
      _priceProvider!.removeListener(_priceListener);
    }
    // attach new
    _priceProvider = priceProvider;
    _priceListener = () => notifyListeners(); // propagate USD changes
    _priceProvider!.addListener(_priceListener);
  }

  void start(String pubkey) {
    if (_pubkey == pubkey && _sub != null) return;

    _sub?.cancel();
    _pubkey = pubkey;
    _isLoading = true;
    notifyListeners();

    _sub = _stream.start(pubkey).listen((lamps) {
      _lamports = lamps;
      if (_isLoading) _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    final key = _pubkey;
    if (key != null) await _stream.refresh(key);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _stream.stop();
    _pubkey = null;
    _lamports = null;
    _isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _priceProvider?.removeListener(_priceListener);
    _sub?.cancel();
    _stream.stop();
    super.dispose();
  }
}
