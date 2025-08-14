import 'dart:async';
import 'dart:convert';
import 'package:skrambl_app/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class WalletBalanceStream {
  final String rpcUrl;
  WebSocketChannel? _channel;
  StreamController<int>? _balanceController;
  dynamic _subscriptionId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isReconnecting = false;
  String? _currentPubkey;
  int? _lastLamports; // keep the latest known value
  Timer? _keepAlive; // for periodic tiny pings
  WalletBalanceStream({
    this.rpcUrl = 'wss://mainnet.helius-rpc.com/?api-key=e9be3c89-9113-4c5d-be19-4dfc99d8c8f4',
  });

  Future<int> _fetchInitialLamports(String pubkey) async {
    try {
      final response = await http.post(
        Uri.parse("https://bernette-tb3sav-fast-mainnet.helius-rpc.com"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "jsonrpc": "2.0",
          "id": 1,
          "method": "getBalance",
          "params": [pubkey],
        }),
      );
      if (response.statusCode != 200) throw Exception('RPC ${response.statusCode}');
      if (response.body.isEmpty) throw Exception('Empty response from RPC');
      final json = jsonDecode(response.body);
      final lamports = json['result']['value'];
      skrLogger.i('Initial balance fetched: $lamports lamports');
      return lamports;
    } catch (e) {
      skrLogger.e('Failed to fetch initial balance: $e');
      return 0;
    }
  }

  Stream<int> start(String pubkey) {
    final reuse =
        _balanceController != null &&
        !_balanceController!.isClosed &&
        _currentPubkey == pubkey &&
        _channel != null;

    //Switching to a new pubkey
    final isSamePubkey = _currentPubkey == pubkey;
    _currentPubkey = pubkey;
    if (!isSamePubkey) _lastLamports = null; // 1)

    if (!reuse) {
      _balanceController?.close(); // just in case
      _balanceController = StreamController<int>.broadcast(
        onListen: () {
          if (_lastLamports != null) {
            // immediately seed the latest value to new subscribers
            _balanceController!.add(_lastLamports!);
          }
        },
      );

      _openAndSubscribe(pubkey); // open WS, subscribe, set handlers
      _refreshOnce(pubkey); // one-off RPC to fetch current balance
    } else {
      // Reusing: still make sure subscriber gets a value *now*
      // Either seed via onListen (above), or push again if you want to force-refresh:
      if (_lastLamports == null) {
        _refreshOnce(pubkey); // if we don't have a cached value yet
      } else {
        // Optionally force a refresh even if we do:
        // _refreshOnce(pubkey);
        scheduleMicrotask(() => _balanceController?.add(_lastLamports!));
      }
    }

    return _balanceController!.stream;
  }

  Future<void> _refreshOnce(String pubkey) async {
    try {
      final lamports = await _fetchInitialLamports(pubkey);
      // Update only if changed
      if (lamports != _lastLamports) {
        _lastLamports = lamports;
        _balanceController?.add(lamports);
      }
    } catch (e) {
      // log but don't crash the stream
      _stopKeepAlive();
    }
  }

  void _openAndSubscribe(String pubkey) {
    _channel?.sink.close(); // close existing if any
    _channel = WebSocketChannel.connect(Uri.parse(rpcUrl));
    _subscriptionId = null;
    _startKeepAlive(); // start periodic pings to keep connection alive
    _channel!.stream.listen(
      (message) {
        final decoded = jsonDecode(message);

        // subscription ack
        if (decoded['result'] != null && _subscriptionId == null) {
          _subscriptionId = decoded['result'];
          skrLogger.i('[SKRAMBL WS] Subscribed with ID: $_subscriptionId');
          _refreshOnce(pubkey);
        }

        // account notifications
        final method = decoded['method'] as String?;
        if (method == 'accountNotification') {
          final value = decoded['params']?['result']?['value'];
          final lamports = (value?['lamports'] as int?) ?? 0;
          // Update only if changed
          if (lamports != _lastLamports) {
            _lastLamports = lamports;
            _balanceController?.add(lamports);
          }
        }

        _reconnectAttempts = 0;
      },
      onError: (e) {
        skrLogger.e('[SKRAMBL WS] Error: $e');
        _scheduleReconnect();
        _stopKeepAlive();
      },
      onDone: () {
        skrLogger.w('[WS] Connection closed');
        _scheduleReconnect();
        _stopKeepAlive();
      },
      cancelOnError: true,
    );

    final subRequest = jsonEncode({
      "jsonrpc": "2.0",
      "id": 1,
      "method": "accountSubscribe",
      "params": [
        pubkey,
        {"encoding": "jsonParsed", "commitment": "processed"},
      ],
    });

    skrLogger.i('[WS] Subscribing to pubkey: $pubkey');
    _channel!.sink.add(subRequest);
  }

  void _scheduleReconnect() {
    if (_isReconnecting || _currentPubkey == null) return;
    _isReconnecting = true;
    _reconnectAttempts++;
    final delay = Duration(seconds: 2 * _reconnectAttempts.clamp(1, 5));
    skrLogger.w('[WS] Reconnecting in ${delay.inSeconds}s...');

    _reconnectTimer = Timer(delay, () {
      skrLogger.i('[WS] Attempting reconnect to $_currentPubkey...');
      _isReconnecting = false;
      _stopKeepAlive();
      _channel?.sink.close();
      _channel = null;
      if (_currentPubkey != null) {
        _openAndSubscribe(_currentPubkey!);
      }
    });
  }

  void stop() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isReconnecting = false;
    _reconnectAttempts = 0;
    _currentPubkey = null;
    _lastLamports = null;
    _stopKeepAlive(); // stop periodic pings
    if (_subscriptionId != null) {
      final unsubRequest = jsonEncode({
        "jsonrpc": "2.0",
        "id": 2,
        "method": "accountUnsubscribe",
        "params": [_subscriptionId],
      });
      _channel?.sink.add(unsubRequest);
      _subscriptionId = null;
    }

    _channel?.sink.close();
    _balanceController?.close();
    _channel = null;
    _subscriptionId = null;
    _balanceController = null;
  }

  Future<void> refresh(String pubkey) async {
    final latest = await _fetchInitialLamports(pubkey);
    // Update only if changed
    if (latest != _lastLamports) {
      _lastLamports = latest;
      _balanceController?.add(latest);
    }
  }

  void _startKeepAlive() {
    _keepAlive?.cancel();
    _keepAlive = Timer.periodic(const Duration(seconds: 40), (_) {
      try {
        _channel?.sink.add(jsonEncode({"jsonrpc": "2.0", "id": 0, "method": "ping"}));
      } catch (_) {}
    });
  }

  void _stopKeepAlive() {
    _keepAlive?.cancel();
    _keepAlive = null;
  }
}
