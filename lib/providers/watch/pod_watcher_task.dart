// lib/pods/watch/pod_watcher_task.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/services/pod_service.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/solana/solana_ws_service.dart';
import 'package:skrambl_app/utils/logger.dart';

class PodWatcherTask {
  final PodDao dao;
  final Pod pod;
  final _done = Completer<void>();
  Timer? _poller;
  StreamSubscription? _wsSub;

  // Keep these as you had them
  final rpc = SolanaClientService().rpcClient;

  // RECOMMENDED: pass a shared instance from above (e.g., via Provider)
  final SolanaWsService ws;

  bool _finished = false;

  PodWatcherTask({required this.dao, required this.pod, SolanaWsService? wsService})
    : ws = wsService ?? SolanaWsService();

  void start({VoidCallback? onDone}) {
    _wireWebSocket(onDone: onDone);
    _startPollingFallback(onDone: onDone);
  }

  void _wireWebSocket({VoidCallback? onDone}) {
    try {
      _wsSub = ws
          .accountSubscribe(
            pod.podPda,
            commitment: 'confirmed', // match your previous HTTP commitment
            encoding: 'base64',
          )
          .listen((acct) async {
            if (_finished) return;

            // Finalized (account closed)
            if (acct == null) {
              await dao.markFinalized(id: pod.id);
              _finish(onDone);
              return;
            }

            // --- Decode account data to detect delivering ---
            // acct['data'] is typically [base64String, "base64"]
            final dataField = acct['data'];
            if (dataField is List && dataField.isNotEmpty && dataField.first is String) {
              try {
                final b64 = dataField.first as String;
                final bytes = base64.decode(b64);
                final int? lastProcess = await parseLastProcessFrom(bytes); // <— your helper
                if (lastProcess == 1) {
                  skrLogger.i('Pod ${pod.podPda} is now delivering');
                  await dao.markDelivering(id: pod.id);
                }
              } catch (_) {
                // Ignore decode errors; next update will try again
              }
            }
          });
    } catch (_) {
      // WS may fail — polling fallback covers it
    }
  }

  void _startPollingFallback({VoidCallback? onDone}) {
    int seconds = 3;
    _poller = Timer.periodic(Duration(seconds: seconds), (t) async {
      try {
        final info = await rpc.getAccountInfo(pod.podPda);
        if (info.value == null) {
          if (_finished) return;
          await dao.markFinalized(id: pod.id);
          _finish(onDone);
        }
      } catch (_) {
        /* ignore transient errors */
      }
      // (optional) increase backoff gradually, cap at e.g. 30s
      if (seconds < 30) {
        seconds += 2;
        _poller?.cancel();
        _startPollingFallback(onDone: onDone);
      }
    });
  }

  void _finish(VoidCallback? onDone) {
    if (_finished) return;
    _finished = true;
    dispose();
    onDone?.call();
    if (!_done.isCompleted) _done.complete();
  }

  void dispose() {
    _poller?.cancel();
    _poller = null;
    _wsSub?.cancel();
    _wsSub = null;
  }
}
