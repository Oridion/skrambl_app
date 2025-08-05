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

  //WalletBalanceStream({this.rpcUrl = 'wss://api.mainnet-beta.solana.com/'});
  WalletBalanceStream({
    this.rpcUrl =
        'wss://mainnet.helius-rpc.com/?api-key=e9be3c89-9113-4c5d-be19-4dfc99d8c8f4',
  });

  Future<int> _fetchInitialLamports(String pubkey) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.mainnet-beta.solana.com"),
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

    // Start listening to updates
    _channel!.stream.listen(
      (message) {
        final decoded = jsonDecode(message);
        skrLogger.i('[SKRAMBL WS] Received: $decoded');

        if (decoded['method'] == 'accountNotification') {
          final value = decoded['params']['result']['value'];
          if (value != null && value['lamports'] != null) {
            final lamports = value['lamports'];
            skrLogger.i('[SKRAMBL WS] New balance: $lamports');
            _balanceController?.add(lamports);
          } else {
            skrLogger.i('[SKRAMBL WS] Account value is null');
            _balanceController?.add(0);
          }
        }

        if (decoded['result'] != null && _subscriptionId == null) {
          _subscriptionId = decoded['result'];
          skrLogger.i('[SKRAMBL WS] Subscribed with ID: $_subscriptionId');
        }
      },
      onError: (e) {
        skrLogger.i('[SKRAMBL WS] Error: $e');
        _balanceController?.addError(e);
      },
      onDone: () {
        skrLogger.i('[SKRAMBL WS] Connection closed');
        _balanceController?.close();
      },
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

    skrLogger.i('[SKRAMBL WS] Subscribing to pubkey: $pubkey');
    _channel!.sink.add(subRequest);

    return _balanceController!.stream;
  }

  void stop() {
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
    _subscriptionId = null;
    _channel = null;
    _balanceController = null;
    skrLogger.i('[SKRAMBL WS] Stream stopped and cleaned up');
  }
}
