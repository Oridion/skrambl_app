import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:skrambl_app/services/wallet_balance_stream.dart';
import 'package:skrambl_app/services/price_service.dart';
import 'package:skrambl_app/utils/logger.dart';

class WalletBalanceProvider extends ChangeNotifier {
  final WalletBalanceStream _stream = WalletBalanceStream();

  String? _pubkey;
  int? _lamports;
  double _usdPrice = 0;
  bool _isLoading = true;

  StreamSubscription<int>? _sub; // use a subscription, not just Stream
  Timer? _priceTimer; // optional: periodic price refresh

  String? get pubkey => _pubkey;
  int? get lamports => _lamports;
  double get solBalance => (_lamports ?? 0) / 1e9;
  double get usdBalance => solBalance * _usdPrice;
  bool get isLoading => _isLoading;

  void start(String pubkey) {
    skrLogger.i("WBM started");

    // Do nothing if we’re already on this key
    if (_pubkey == pubkey && _sub != null) return;

    // If switching keys, clean up first
    _sub?.cancel();
    _priceTimer?.cancel();

    _pubkey = pubkey;
    _isLoading = true;
    notifyListeners();

    // Subscribe to lamports stream
    _sub = _stream.start(pubkey).listen((lamps) {
      _lamports = lamps;

      // ✅ Update balance immediately (don’t await price)
      if (_isLoading) _isLoading = false;
      notifyListeners();
    });

    // Kick a one-off price fetch (don’t await the stream listener)
    _refreshPrice();

    // Optional: keep price fresh every 60s without blocking balance updates
    _priceTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _refreshPrice();
    });
  }

  Future<void> _refreshPrice() async {
    try {
      final price = await fetchSolPriceUsd();
      if (price != _usdPrice) {
        _usdPrice = price;
        notifyListeners(); // only USD line will change in UI
      }
    } catch (e) {
      // keep last price; optionally log
      skrLogger.w('Price refresh failed: $e');
    }
  }

  Future<void> refresh() async {
    final key = _pubkey;
    if (key != null) {
      await _stream.refresh(key); // triggers a lamports push
    }
    // You could also refresh price here if desired:
    // await _refreshPrice();
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _priceTimer?.cancel();
    _priceTimer = null;

    _stream.stop();

    _pubkey = null;
    _lamports = null;
    _usdPrice = 0;
    _isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _priceTimer?.cancel();
    _stream.stop();
    super.dispose();
  }
}
