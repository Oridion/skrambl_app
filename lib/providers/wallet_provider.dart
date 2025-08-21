// lib/providers/wallet_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/services/wallet_balance_stream.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider(PriceProvider priceProvider) {
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

  // Called by ProxyProvider.update
  void attachPriceProvider(PriceProvider priceProvider) {
    _attachPriceProvider(priceProvider);
    notifyListeners(); // propagate USD recalcs
  }

  void _attachPriceProvider(PriceProvider priceProvider) {
    if (_priceProvider != null) {
      _priceProvider!.removeListener(_priceListener);
    }
    _priceProvider = priceProvider;
    _priceListener = () => notifyListeners(); // when SOL→USD changes
    _priceProvider!.addListener(_priceListener);
  }

  /// Follow this account. Pass null to clear.
  Future<void> setAccount(String? pubkey) async {
    if (_pubkey == pubkey && _sub != null) return;

    _sub?.cancel();
    _sub = null;
    _pubkey = pubkey;

    if (pubkey == null) {
      _lamports = null;
      _isLoading = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _sub = _stream.start(pubkey).listen((lamps) {
      _lamports = lamps;
      if (_isLoading) _isLoading = false;
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> refresh() async {
    final key = _pubkey;
    if (key != null) await _stream.refresh(key);
  }

  @override
  void dispose() {
    _priceProvider?.removeListener(_priceListener);
    _sub?.cancel();
    _stream.stop();
    super.dispose();
  }
}
