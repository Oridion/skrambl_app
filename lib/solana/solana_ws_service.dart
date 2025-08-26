import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:skrambl_app/constants/app.dart';

/// Create a single instance and reuse it across watchers to share one socket.
class SolanaWsService {
  WebSocketChannel? _chan;
  StreamSubscription? _chanSub;

  /// Broadcast of all decoded JSON messages from the socket
  final _incoming = StreamController<Map<String, dynamic>>.broadcast();

  /// Incrementing request id for JSON-RPC
  int _nextId = 1;

  /// Number of active WS subscriptions (to auto-close when zero)
  int _activeSubs = 0;

  /// Optional keepalive
  Timer? _pingTimer;

  /// How long to wait for a subscription ack before failing
  final Duration ackTimeout;

  /// Optional periodic ping (set to null to disable)
  final Duration? pingInterval;

  SolanaWsService({this.ackTimeout = const Duration(seconds: 8), this.pingInterval});

  // ---------- Public API ----------

  /// Subscribe to account changes for [pubkey].
  /// Emits the raw `value` object or `null` when the account doesn’t exist / is closed.
  Stream<Map<String, dynamic>?> accountSubscribe(
    String pubkey, {
    String encoding = 'base64',
    String commitment = 'confirmed',
  }) {
    return _subscribe<Map<String, dynamic>?>(
      method: 'accountSubscribe',
      params: [
        pubkey,
        {'encoding': encoding, 'commitment': commitment},
      ],
      notificationMethod: 'accountNotification',
      extractor: (msg) => (msg['params']?['result']?['value'] as Map?)?.cast<String, dynamic>(),
      unsubscribeMethod: 'accountUnsubscribe',
      unsubscribeParams: (subId) => [subId],
    );
  }

  /// Subscribe to a transaction signature until the given commitment (default: finalized).
  /// Emits the full result map (check `err`, `slot`, `confirmationStatus`).
  Stream<Map<String, dynamic>> signatureSubscribe(String signature, {String commitment = 'finalized'}) {
    return _subscribe<Map<String, dynamic>>(
      method: 'signatureSubscribe',
      params: [
        signature,
        {'commitment': commitment},
      ],
      notificationMethod: 'signatureNotification',
      extractor: (msg) => (msg['params']?['result'] as Map).cast<String, dynamic>(),
      unsubscribeMethod: 'signatureUnsubscribe',
      unsubscribeParams: (subId) => [subId],
    );
  }

  /// Manually close the socket and streams (e.g., on app terminate).
  /// Do not call this during normal operation if you still plan to resubscribe later.
  Future<void> dispose() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    await _chanSub?.cancel();
    await _chan?.sink.close();
    await _incoming.close();
    _chanSub = null;
    _chan = null;
  }

  // ---------- Core subscribe plumbing ----------

  Stream<T> _subscribe<T>({
    required String method,
    required List<dynamic> params,
    required String notificationMethod,
    required T Function(Map<String, dynamic> message) extractor,
    required String unsubscribeMethod,
    required List<dynamic> Function(int subId) unsubscribeParams,
  }) {
    _ensureConnected();

    final requestId = _nextId++;
    final ack = Completer<int>();

    // Listen for the ack containing the subscription id: {"id":<requestId>, "result": <subId>}
    final ackListener = _incoming.stream.listen((msg) {
      if (msg['id'] == requestId && msg.containsKey('result')) {
        final r = msg['result'];
        if (r is int) {
          ack.complete(r);
        } else if (r is Map && r['subscription'] is int) {
          ack.complete(r['subscription'] as int);
        }
      }
    });

    // Send subscribe request
    final subscribePayload = {'jsonrpc': '2.0', 'id': requestId, 'method': method, 'params': params};
    _chan!.sink.add(jsonEncode(subscribePayload));

    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () async {
        _activeSubs++;

        int subId;
        try {
          subId = await ack.future.timeout(ackTimeout);
        } catch (e) {
          // Fail fast if no ack received
          controller.addError(StateError('WS subscribe ack timeout for $method'));
          await ackListener.cancel();
          await controller.close();
          _decrementAndMaybeClose();
          return;
        }

        // Forward only notifications for this subscription id
        final notifSub = _incoming.stream
            .where((msg) => msg['method'] == notificationMethod)
            .where((msg) => msg['params']?['subscription'] == subId)
            .map<T>((msg) {
              try {
                return extractor(msg);
              } catch (e, st) {
                // Surface extractor errors to the consumer
                // ignore: only_throw_errors
                throw StateError('WS extractor error for $notificationMethod: $e\n$st');
              }
            })
            .listen(controller.add, onError: controller.addError, onDone: controller.close);

        // On cancel: unsubscribe and maybe close the socket if no subs left
        controller.onCancel = () async {
          await notifSub.cancel();
          await ackListener.cancel();

          final unId = _nextId++;
          final unsubscribePayload = {
            'jsonrpc': '2.0',
            'id': unId,
            'method': unsubscribeMethod,
            'params': unsubscribeParams(subId),
          };
          try {
            _chan?.sink.add(jsonEncode(unsubscribePayload));
          } catch (_) {
            // Socket may already be closed; ignore
          }

          _decrementAndMaybeClose();
        };
      },
    );

    return controller.stream;
  }

  void _ensureConnected() {
    // Reuse connection while there are active subs
    if (_chan != null) return;

    final url = AppConstants.wsClientRawURL; // MUST be a wss:// endpoint
    _chan = WebSocketChannel.connect(Uri.parse(url));
    _chanSub = _chan!.stream.listen(
      (data) {
        try {
          // Handle text or binary frames
          final String text = switch (data) {
            final String s => s,
            final List<int> bytes => utf8.decode(bytes),
            _ => data.toString(),
          };
          final msg = jsonDecode(text) as Map<String, dynamic>;
          _incoming.add(msg);
        } catch (_) {
          // ignore malformed frames
        }
      },
      onError: (_) {
        // Keep simple: allow callers to fall back to polling.
        // You can add reconnect logic here later if desired.
      },
      onDone: () {
        // Socket closed by server; will lazily reconnect on next subscribe.
        _chanSub = null;
        _chan = null;
      },
    );

    // Optional keepalive
    _pingTimer?.cancel();
    if (pingInterval != null) {
      _pingTimer = Timer.periodic(pingInterval!, (_) {
        try {
          // Any benign method works as a keepalive. getHealth is cheap.
          final id = _nextId++;
          _chan?.sink.add(jsonEncode({'jsonrpc': '2.0', 'id': id, 'method': 'getHealth'}));
        } catch (_) {
          /* ignore */
        }
      });
    }
  }

  void _decrementAndMaybeClose() async {
    _activeSubs = (_activeSubs - 1).clamp(0, 1 << 30);
    if (_activeSubs == 0) {
      _pingTimer?.cancel();
      _pingTimer = null;
      await _chanSub?.cancel();
      await _chan?.sink.close();
      _chanSub = null;
      _chan = null;
    }
  }
}
