// lib/pods/watch/pod_watcher_task.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
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
  final _kInstantNoPoll = Duration(seconds: 30);
  final _kInstantPollEvery = Duration(seconds: 3);
  final _kInstantPollCutoff = Duration(seconds: 120); // keep in sync with your timeout
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
        final info = await rpc.getAccountInfo(pod.podPda!);
        //If null then it completed successfully.
        if (info.value == null) {
          _finish(onDone);
        }

        // Failed pod!
        skrLogger.w('[POD BACKUP TIMER] Instant pod timed out (>120s), marking failed: ${pod.id}');
        await dao.markFailed(id: pod.id, message: 'Timeout while waiting for confirmation');
        _finish(onDone);
      });
    } else {
      // Delayed: rely solely on WS (no polling / no timeout)
      skrLogger.i('Delayed pod watcher: WS only for ${pod.id}');
      _scheduleDelayedPoll();
    }
  }

  void _wireWebSocket({VoidCallback? onDone}) {
    try {
      _wsSub = ws.accountSubscribe(pod.podPda!, commitment: 'finalized', encoding: 'base64').listen((
        acct,
      ) async {
        if (_finished) return;
        //Debug log.
        //skrLogger.i('[WS] raw: ${const JsonEncoder.withIndent('  ').convert(acct)}');

        if (acct == null) {
          skrLogger.i("[WS] ACCOUNT NULL.");
          return;
        }

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
          skrLogger.i("[WS] account is zeroed out");
          // If we never showed delivering, briefly surface it for UX continuity
          if (!_seenDelivering) {
            skrLogger.i("[WS] Pod delivering was never seen. Marking delivering");
            onPhase?.call(pod.id, TransactionPhase.delivering);
            await Future.delayed(const Duration(milliseconds: 250));
            _seenDelivering = true;
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

            //skrLogger.i(jsonEncode(live.toJson()));

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

    // 0–30s: no polling; schedule first poll at 30s mark
    if (elapsed < _kInstantNoPoll) {
      final wait = _kInstantNoPoll - elapsed;
      _pollTimer?.cancel();
      _pollTimer = Timer(wait, () => _pollOnce(onDone: onDone));
      return;
    }

    // 30–120s: poll every ~3s with a tiny jitter to avoid thundering herd
    if (elapsed < _kInstantPollCutoff) {
      final jitterMs = 100 + math.Random.secure().nextInt(400); // 100–499 ms
      final nextDelay = _kInstantPollEvery + Duration(milliseconds: jitterMs);
      _pollTimer?.cancel();
      _pollTimer = Timer(nextDelay, () => _pollOnce(onDone: onDone));
      return;
    }

    // >=120s: stop scheduling; rely on the existing 2-minute timeout
    _pollTimer?.cancel();
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

  // ---------- Polling (DELAYED ONLY) ----------
  void _scheduleDelayedPoll({VoidCallback? onDone}) {
    if (_finished || _isInstant) return;
    _pollTimer?.cancel();
    _pollTimer = Timer(const Duration(seconds: 10), () => _pollDelayedOnce(onDone: onDone));
  }

  Future<void> _pollDelayedOnce({VoidCallback? onDone}) async {
    if (_finished || _isInstant) return;

    skrLogger.i("[SNAP] Fetching delayed pod from snapshot");
    final snap = await fetchPodSnapshot(pod.podPda!);

    //If pod snapshot is closed (account data on chain not found)
    if (snap.isClosedFinalized) {
      skrLogger.i("[SNAP] pod is finalized");
      // If pod was never marked delivering, then we need to mark it deliverying first.
      if (!_seenDelivering) {
        skrLogger.i("[SNAP] pod has not been delivered. Marking delivering before finalization");
        onPhase?.call(pod.id, TransactionPhase.delivering);
        await Future.delayed(const Duration(milliseconds: 200));
        _seenDelivering = true;
      }
      final changed = await dao.markFinalized(id: pod.id);
      if (changed) {
        skrLogger.i("[SNAP] finalization marked. Closing out.");
        onPhase?.call(pod.id, TransactionPhase.completed);
        _finish(onDone);
      }
      return;
    }

    // If account still exists and is ours, use parsed pod to detect delivering:
    final live = snap.pod;
    if (live != null) {
      final delivering =
          (live.mode == 0 && live.lastProcess == 1) ||
          (live.mode != 0 && (live.nextProcess == 1 || live.lastProcess == 1));
      if (delivering && !_seenDelivering) {
        _seenDelivering = true;
        onPhase?.call(pod.id, TransactionPhase.delivering);
        await dao.markDelivering(id: pod.id);
      }
    }

    // final pod = await fetchPodAccount(podPda: pod.podPda!);

    // final info = await rpc.getAccountInfo(pod.podPda!);
    // if (info.value == null) {
    //   // Account closed – we definitely finalized.
    //   skrLogger.i("[Pod Watcher] (delayed) account disappeared, marking finalized");
    //   await dao.markFinalized(id: pod.id);
    //   onPhase?.call(pod.id, TransactionPhase.completed);
    //   _finish(onDone);
    //   return;
    // }

    // // Optional: decode here too to catch delivering if WS missed it
    // final data = info.value!.data;
    // if (data != null && data.isNotEmpty) {
    //   try {
    //     // Depending on your RPC client, data may be already base64 or structured.
    //     // Ensure this path decodes bytes → model.Pod like in WS section.
    //     final model.Pod? live = await parseAccountInfoToPod(info.value!);
    //     if (live != null) {
    //       final delivering =
    //           (live.mode == 0 && live.lastProcess == 1) ||
    //           (live.mode != 0 && (live.nextProcess == 1 || live.lastProcess == 1));
    //       if (delivering && !_seenDelivering) {
    //         _seenDelivering = true;
    //         onPhase?.call(pod.id, TransactionPhase.delivering);
    //         await dao.markDelivering(id: pod.id);
    //       }
    //     }
    //   } catch (_) {
    //     /* ignore */
    //   }
    // }

    //_scheduleDelayedPoll(onDone: onDone);
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
