import 'dart:async';
import 'dart:convert';
import 'package:skrambl_app/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class WalletBalanceStream {
  final String rpcUrl;
  WebSocketChannel? _channel;
  bool _hasListener = false;
  bool _intentionalClose = false;
  int? _pendingSubReqId;
  StreamController<int>? _balanceController;
  dynamic _subscriptionId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isReconnecting = false;
  String? _currentPubkey;
  int? _lastLamports; // keep the latest known value
  Timer? _keepAlive; // for periodic tiny pings
  int? _lastSubReqId;
  int? _lastUnsubReqId;
  String? _pendingPubkey;
  String? _subscribedPubkey;
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
        _channel != null &&
        _subscriptionId != null; // must already be subscribed

    final isSamePubkey = _currentPubkey == pubkey;
    final prevSubId = _subscriptionId; // keep previous sub id
    _currentPubkey = pubkey;

    if (!isSamePubkey) {
      _lastLamports = null;
      // unsubscribe old, then subscribe new on the SAME socket
      if (prevSubId != null) _sendUnsubscribe(prevSubId);
    }

    if (!reuse) {
      _balanceController?.close();
      _balanceController = StreamController<int>.broadcast(
        onListen: () {
          if (_lastLamports != null) {
            _balanceController!.add(_lastLamports!);
          }
        },
      );
      _sendSubscribe(pubkey);
    } else {
      if (_lastLamports == null) {
        _refreshOnce(pubkey);
      } else {
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

  void _ensureChannelConnected() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(Uri.parse(rpcUrl));
    _subscriptionId = null;
    _startKeepAlive();

    if (!_hasListener) {
      _hasListener = true;
      _channel!.stream.listen(
        (message) {
          final decoded = jsonDecode(message);

          // 1) Handle responses (they have an "id")
          final respId = decoded['id'];
          if (respId != null) {
            // subscribe ack
            if (respId == _lastSubReqId || respId == _pendingSubReqId) {
              final result = decoded['result'];
              if (result is int) {
                _subscriptionId = result;
                _subscribedPubkey = _pendingPubkey;
                skrLogger.i('[SKRAMBL WS] Subscribed with ID: $_subscriptionId to $_subscribedPubkey');
                if (_subscribedPubkey != null) _refreshOnce(_subscribedPubkey!);
              }
              _lastSubReqId = null;
              _pendingSubReqId = null; // <-- clear pending flag
              _pendingPubkey = null;
              _reconnectAttempts = 0;
              return;
            }

            // unsubscribe ack
            if (respId == _lastUnsubReqId) {
              // result is typically true; clear current subscription
              _subscriptionId = null;
              _subscribedPubkey = null;
              skrLogger.i('[SKRAMBL WS] Unsubscribe ack received.');
              _lastUnsubReqId = null;
            }

            _reconnectAttempts = 0;
            return; // handled a response
          }

          // 2) Handle notifications (they have a "method")
          final method = decoded['method'] as String?;
          if (method == 'accountNotification') {
            // Ensure this notification is for our current subscription id
            final subNum = decoded['params']?['subscription'];
            if (_subscriptionId != null && subNum != _subscriptionId) {
              // stale notification from a previous sub; ignore
              return;
            }

            final value = decoded['params']?['result']?['value'];
            final lamports = (value?['lamports'] as int?) ?? 0;
            if (lamports != _lastLamports) {
              _lastLamports = lamports;
              _balanceController?.add(lamports);
            }
          }
        },
        onError: (e) {
          skrLogger.e('[SKRAMBL WS] Error: $e');
          _stopKeepAlive();
          _scheduleReconnect();
        },
        onDone: () {
          skrLogger.w('[WS] Connection closed');
          _stopKeepAlive();
          if (_intentionalClose) {
            _intentionalClose = false; // don't reconnect
            return;
          }
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    }
  }

  void _sendSubscribe(String pubkey) {
    _ensureChannelConnected();

    // Already fully subscribed to this key
    if (_subscriptionId != null && _subscribedPubkey == pubkey) {
      skrLogger.i('[WS] Already subscribed to $pubkey (reuse).');
      if (_lastLamports != null) {
        scheduleMicrotask(() => _balanceController?.add(_lastLamports!));
      }
      return;
    }

    // 🔒 Prevent duplicate subscribe while one is in-flight for same key
    if (_pendingSubReqId != null && _pendingPubkey == pubkey) {
      skrLogger.i('[WS] Subscribe already pending for $pubkey (reqId=$_pendingSubReqId) — skipping.');
      return;
    }

    final reqId = DateTime.now().millisecondsSinceEpoch;
    _lastSubReqId = reqId;
    _pendingSubReqId = reqId; // <-- mark in-flight
    _pendingPubkey = pubkey;

    final subRequest = jsonEncode({
      "jsonrpc": "2.0",
      "id": reqId,
      "method": "accountSubscribe",
      "params": [
        pubkey,
        {"encoding": "jsonParsed", "commitment": "processed"},
      ],
    });
    skrLogger.i('[WS] Subscribing to $pubkey (id=$reqId)');
    _channel!.sink.add(subRequest);
  }

  void _sendUnsubscribe(dynamic subId) {
    if (_channel == null || subId == null) return;
    final reqId = DateTime.now().millisecondsSinceEpoch;
    _lastUnsubReqId = reqId;

    // If we were mid-subscribe to the same key, cancel the pending markers
    if (_pendingSubReqId != null && _pendingPubkey == _subscribedPubkey) {
      _pendingSubReqId = null;
      _pendingPubkey = null;
    }

    final unsub = jsonEncode({
      "jsonrpc": "2.0",
      "id": reqId,
      "method": "accountUnsubscribe",
      "params": [subId],
    });
    skrLogger.i('[WS] Unsubscribing (subId=$subId, id=$reqId)');
    _channel!.sink.add(unsub);
  }

  void _scheduleReconnect() {
    if (_isReconnecting || _currentPubkey == null) return;

    _isReconnecting = true;
    _reconnectTimer?.cancel();

    final attempt = (++_reconnectAttempts).clamp(1, 5);
    final delay = Duration(seconds: 2 * attempt);
    skrLogger.w('[WS] Reconnecting in ${delay.inSeconds}s...');

    _reconnectTimer = Timer(delay, () {
      skrLogger.i('[WS] Attempting reconnect to $_currentPubkey...');
      _isReconnecting = false;

      // Tear down without triggering another auto-reconnect from onDone
      _intentionalClose = true;
      try {
        _channel?.sink.close();
      } catch (_) {}
      _channel = null;
      _subscriptionId = null;

      if (_currentPubkey != null) {
        _ensureChannelConnected(); // opens socket and attaches the single listener
        _sendSubscribe(_currentPubkey!); // resubscribe on the same socket
        // _refreshOnce will be called after the subscription ACK in the listener
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
    _stopKeepAlive();

    if (_subscriptionId != null) {
      _sendUnsubscribe(_subscriptionId);
    }

    _intentionalClose = true;
    _channel?.sink.close();
    _channel = null;

    _balanceController?.close();
    _balanceController = null;
    _subscriptionId = null;
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
        _channel?.sink.add(
          jsonEncode({"jsonrpc": "2.0", "id": DateTime.now().millisecondsSinceEpoch, "method": "ping"}),
        );
      } catch (_) {}
    });
  }

  void _stopKeepAlive() {
    _keepAlive?.cancel();
    _keepAlive = null;
  }
}
