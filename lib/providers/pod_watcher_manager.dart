// lib/pods/watch/pod_watcher_manager.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/providers/watch/pod_watcher_task.dart';
import 'package:skrambl_app/solana/solana_ws_service.dart';

class PodWatcherManager with ChangeNotifier {
  final PodDao dao;

  /// Shared WS instance for all tasks (single socket).
  final SolanaWsService ws;

  /// key = pod.podPda
  final Map<String, PodWatcherTask> _active = {};

  StreamSubscription<List<Pod>>? _sub;
  bool _started = false;

  PodWatcherManager(this.dao, {SolanaWsService? wsService}) : ws = wsService ?? SolanaWsService();

  bool get isRunning => _started;
  int get activeCount => _active.length;

  void start() {
    if (_started) return;
    _started = true;

    _sub = dao.watchPendingPods().listen((pods) {
      // Build the desired set of active PDAs
      final desired = pods
          .where((p) => p.podPda != null /* && isWatchable(p.status) */)
          .map((p) => p.podPda)
          .toSet();

      // Start new watchers
      for (final p in pods) {
        final pda = p.podPda;
        if (pda == null) continue;
        if (_active.containsKey(pda)) continue;

        final task = PodWatcherTask(dao: dao, pod: p, wsService: ws);
        _active[pda] = task;
        task.start(
          onDone: () {
            // remove only if still mapped to this pda
            final current = _active[pda];
            if (identical(current, task)) {
              _active.remove(pda);
              notifyListeners();
            }
          },
        );
      }

      // Stop watchers no longer needed
      final toStop = _active.keys.where((k) => !desired.contains(k)).toList();
      for (final k in toStop) {
        _active[k]?.dispose();
        _active.remove(k);
      }

      // notify for activeCount changes
      notifyListeners();
    });
  }

  void stop() {
    if (!_started) return;
    _started = false;

    _sub?.cancel();
    _sub = null;

    for (final t in _active.values) {
      t.dispose();
    }
    _active.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Optional: centralize which statuses should be watched
/*bool isWatchable(int statusIndex) {
  final s = PodStatus.values[statusIndex];
  return s == PodStatus.submitted ||
         s == PodStatus.scrambling ||
         s == PodStatus.delivering;
}*/
