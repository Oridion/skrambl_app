import 'dart:async';
import 'dart:convert';
import 'package:skrambl_app/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class WalletBalanceStream {
  final String rpcUrl;
  WebSocketChannel? _channel;
  StreamController<int>? _balanceController;
  int? _subscriptionId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isReconnecting = false;
  String? _currentPubkey;

  WalletBalanceStream({
    this.rpcUrl =
        'wss://mainnet.helius-rpc.com/?api-key=e9be3c89-9113-4c5d-be19-4dfc99d8c8f4',
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

      final json = jsonDecode(response.body);
      final lamports = json['result']['value'];
      skrLogger.i('[SKRAMBL] Initial balance fetched: $lamports lamports');
      return lamports;
    } catch (e) {
      skrLogger.e('[SKRAMBL] Failed to fetch initial balance: $e');
      return 0;
    }
  }

  Stream<int> start(String pubkey) {
    _currentPubkey = pubkey;

    if (_balanceController != null && !_balanceController!.isClosed) {
      skrLogger.i('[SKRAMBL WS] Reusing existing balance stream');
      return _balanceController!.stream;
    }

    _balanceController = StreamController<int>();
    _channel = WebSocketChannel.connect(Uri.parse(rpcUrl));

    // Emit initial balance
    _fetchInitialLamports(pubkey).then((initialLamports) {
      _balanceController?.add(initialLamports);
    });

    // Listen for updates
    _channel!.stream.listen(
      (message) {
        final decoded = jsonDecode(message);
        skrLogger.i('[SKRAMBL WS] Received: $decoded');

        if (decoded['method'] == 'accountNotification') {
          final value = decoded['params']['result']['value'];
          final lamports = value?['lamports'] ?? 0;
          skrLogger.i('[SKRAMBL WS] New balance: $lamports');
          _balanceController?.add(lamports);
        }

        if (decoded['result'] != null && _subscriptionId == null) {
          _subscriptionId = decoded['result'];
          skrLogger.i('[SKRAMBL WS] Subscribed with ID: $_subscriptionId');
        }

        // Reset reconnect attempts after a good message
        _reconnectAttempts = 0;
      },
      onError: (e) {
        skrLogger.e('[SKRAMBL WS] Error: $e');
        _scheduleReconnect();
      },
      onDone: () {
        skrLogger.w('[SKRAMBL WS] Connection closed');
        _scheduleReconnect();
      },
      cancelOnError: true,
    );

    // Subscribe to account
    final subRequest = jsonEncode({
      "jsonrpc": "2.0",
      "id": 1,
      "method": "accountSubscribe",
      "params": [
        pubkey,
        {"encoding": "jsonParsed", "commitment": "processed"},
      ],
    });

    skrLogger.i('[SKRAMBL WS] Subscribing to pubkey: $pubkey');
    _channel!.sink.add(subRequest);

    return _balanceController!.stream;
  }

  void stop() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isReconnecting = false;
    _reconnectAttempts = 0;
    _currentPubkey = null;

    if (_subscriptionId != null) {
      final unsubRequest = jsonEncode({
        "jsonrpc": "2.0",
        "id": 2,
        "method": "accountUnsubscribe",
        "params": [_subscriptionId],
      });
      _channel?.sink.add(unsubRequest);
    }

    _channel?.sink.close();
    _balanceController?.close();
    _channel = null;
    _subscriptionId = null;
    _balanceController = null;

    //skrLogger.i('[SKRAMBL WS] Stream stopped and cleaned up');
  }

  Future<void> refresh(String pubkey) async {
    final latest = await _fetchInitialLamports(pubkey);
    //skrLogger.i('[SKRAMBL] Manual refresh: $latest lamports');
    _balanceController?.add(latest);
  }

  void _scheduleReconnect() {
    if (_isReconnecting || _currentPubkey == null) return;

    _isReconnecting = true;
    _reconnectAttempts++;
    final delay = Duration(seconds: 2 * _reconnectAttempts.clamp(1, 5));

    skrLogger.w('[SKRAMBL WS] Reconnecting in ${delay.inSeconds}s...');

    _reconnectTimer = Timer(delay, () {
      skrLogger.i('[SKRAMBL WS] Attempting reconnect to $_currentPubkey...');
      _isReconnecting = false;
      _channel?.sink.close();
      _channel = null;
      start(_currentPubkey!);
    });
  }
}
