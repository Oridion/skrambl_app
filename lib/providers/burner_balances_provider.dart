// lib/providers/burner_balances_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skrambl_app/data/burner_dao.dart';

class BurnerBalancesProvider extends ChangeNotifier {
  final BurnerDao dao;
  final String rpcHttpUrl; // e.g. your Helius HTTP endpoint
  final Duration refreshEvery;

  StreamSubscription? _sub;
  Timer? _poll;
  final Map<String, int> _lamports = {}; // pubkey -> lamports
  List<String> _currentPubkeys = [];

  BurnerBalancesProvider({
    required this.dao,
    required this.rpcHttpUrl,
    this.refreshEvery = const Duration(seconds: 45),
  }) {
    _wire();
  }

  void _wire() {
    _sub = dao.watchAllActive().listen((rows) async {
      final keys = rows.map((b) => b.pubkey).toSet().toList();
      _currentPubkeys = keys;
      await _refreshNow(); // immediate refresh on list change
      _startTimer();
    });
  }

  void _startTimer() {
    _poll?.cancel();
    _poll = Timer.periodic(refreshEvery, (_) => _refreshNow());
  }

  Future<void> _refreshNow() async {
    if (_currentPubkeys.isEmpty) return;
    try {
      // Batch get via getMultipleAccounts
      final body = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getMultipleAccounts",
        "params": [
          _currentPubkeys,
          {"encoding": "base64", "commitment": "processed"},
        ],
      };
      final resp = await http.post(
        Uri.parse(rpcHttpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (resp.statusCode != 200 || resp.body.isEmpty) return;
      final json = jsonDecode(resp.body);
      final values = (json['result']?['value'] as List?) ?? const [];

      // Map back by index
      for (var i = 0; i < _currentPubkeys.length; i++) {
        final v = i < values.length ? (values[i] as Map<String, dynamic>?) : null;
        final lam = (v?['lamports'] as int?) ?? 0; // field exists on account object
        _lamports[_currentPubkeys[i]] = lam;
      }
      notifyListeners();
    } catch (_) {
      /* swallow; keep last known */
    }
  }

  int lamportsFor(String pubkey) => _lamports[pubkey] ?? 0;

  @override
  void dispose() {
    _sub?.cancel();
    _poll?.cancel();
    super.dispose();
  }
}
