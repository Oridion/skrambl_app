// lib/pods/watch/pod_watcher_task.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/services/pod_service.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/solana/solana_ws_service.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:skrambl_app/models/pod_model.dart' as model;

class PodWatcherTask {
  final PodDao dao;
  final Pod pod;
  final SolanaWsService ws;
  final void Function(String podId, TransactionPhase phase)? onPhase;
  final rpc = SolanaClientService().rpcClient;

  StreamSubscription? _wsSub;
  Timer? _pollTimer;
  Timer? _timeoutTimer;

  late final DateTime _startedAt;
  bool _finished = false;

  bool _seenDelivering = false;

  PodWatcherTask({required this.dao, required this.pod, this.onPhase, SolanaWsService? wsService})
    : ws = wsService ?? SolanaWsService() {
    assert(pod.podPda != null, 'Watcher should only be created for pods with a PDA');
  }

  bool get _isInstant => (pod.delaySeconds) == 0;
  bool get _isDelayed => !_isInstant;

  void start({VoidCallback? onDone}) {
    _startedAt = DateTime.now();

    // Always wire WS (cheap and instant)
    _wireWebSocket(onDone: onDone);

    if (_isInstant) {
      // Start “no poll until 30s” cadence
      _scheduleNextPoll(onDone: onDone);
      // Hard fail if > 2 minutes and still not finalized
      _timeoutTimer = Timer(const Duration(minutes: 2), () async {
        try {
          final info = await rpc.getAccountInfo(pod.podPda!);
          if (info.value == null) {
            skrLogger.i("[WS] Force finalized pod over 2 minutes.");
            // It actually finalized; we just missed the WS
            await dao.markFinalized(id: pod.id);
            _finish(onDone);
            return;
          }
        } catch (_) {
          // ignore and proceed to fail
        }

        skrLogger.w('Instant pod timed out (>120s), marking failed: ${pod.id}');
        await dao.markFailed(id: pod.id, message: 'Timeout while waiting for confirmation');
        _finish(onDone);
      });
    } else {
      // Delayed: rely solely on WS (no polling / no timeout)
      skrLogger.i('Delayed pod watcher: WS only for ${pod.id}');
    }
  }

  void _wireWebSocket({VoidCallback? onDone}) {
    try {
      _wsSub = ws.accountSubscribe(pod.podPda!, commitment: 'finalized', encoding: 'base64').listen((
        acct,
      ) async {
        if (_finished) return;
        //Debug log.
        skrLogger.i('[WS] raw: ${const JsonEncoder.withIndent('  ').convert(acct)}');

        if (acct == null) return;

        // ---- Closed / zeroed? (Helius pattern) ----
        final lamports = (acct['lamports'] as num?)?.toInt() ?? -1;
        final owner = acct['owner'] as String? ?? '';
        final space = (acct['space'] as num?)?.toInt() ?? -1;
        final data = acct['data'];

        final emptyData = data is List && data.isNotEmpty && (data.first as String?)?.isEmpty == true;
        final isSystemOwner = owner == '11111111111111111111111111111111';
        final isZeroed = lamports == 0 && space == 0 && isSystemOwner && emptyData;

        // Account closed => finalized
        if (isZeroed) {
          // If we never showed delivering, briefly surface it for UX continuity
          if (!_seenDelivering) {
            onPhase?.call(pod.id, TransactionPhase.delivering);
            await Future.delayed(const Duration(milliseconds: 250));
          }
          skrLogger.i("[WS] Pod closed. Marking finalized");
          await dao.markFinalized(id: pod.id); // persist to DB
          onPhase?.call(pod.id, TransactionPhase.completed); // immediate UI update
          _finish(onDone);
          return;
        }

        // Detect delivering stage depending on mode
        // ---- Live account: decode to detect "delivering" ----
        if (data is List && data.isNotEmpty && data.first is String) {
          try {
            final b64 = data.first as String;
            final bytes = base64.decode(b64);
            final model.Pod? live = await parsePod(bytes);
            if (live == null) return;

            skrLogger.i(jsonEncode(live.toJson()));

            // If it is delivering.
            final delivering =
                (live.mode == 0 && live.lastProcess == 1) || // instant: lastProcess==1
                (live.mode != 0 && live.nextProcess == 1); // delayed: nextProcess==1
            if (delivering && !_seenDelivering) {
              _seenDelivering = true;
              onPhase?.call(pod.id, TransactionPhase.delivering);
              await dao.markDelivering(id: pod.id);
              return;
            }
          } catch (e) {
            skrLogger.w('WS decode/parse error: $e');
          }
        }
      }, cancelOnError: false);
    } catch (e) {
      skrLogger.w('WS subscribe failed for ${pod.id}: $e');
    }
  }

  // ---------- Polling (INSTANT ONLY) ----------
  void _scheduleNextPoll({VoidCallback? onDone}) {
    if (_finished || _isDelayed) return;

    final elapsed = DateTime.now().difference(_startedAt);
    const initialWait = Duration(seconds: 30);
    Duration nextDelay;

    if (elapsed < initialWait) {
      // Do not poll yet; wait until 30s mark
      nextDelay = initialWait - elapsed;
    } else if (elapsed < const Duration(seconds: 90)) {
      // 30–90s: poll aggressively
      nextDelay = const Duration(seconds: 2);
    } else if (elapsed < const Duration(minutes: 3)) {
      // Past typical window: back off
      nextDelay = const Duration(seconds: 6);
    } else {
      // Long tail: poll occasionally
      nextDelay = const Duration(seconds: 12);
    }

    _pollTimer?.cancel();
    _pollTimer = Timer(nextDelay, () => _pollOnce(onDone: onDone));
  }

  Future<void> _pollOnce({VoidCallback? onDone}) async {
    if (_finished || _isDelayed) return;

    try {
      final info = await rpc.getAccountInfo(pod.podPda!);
      if (info.value == null) {
        skrLogger.i("[Pod Watcher] Pod not found. Marking finalized");
        await dao.markFinalized(id: pod.id);
        _finish(onDone);
        return;
      }
    } catch (_) {
      // ignore transient RPC failures
    }

    _scheduleNextPoll(onDone: onDone);
  }

  void _finish(VoidCallback? onDone) {
    if (_finished) return;
    _finished = true;
    dispose();
    onDone?.call();
  }

  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _wsSub?.cancel();
    _wsSub = null;
  }
}
