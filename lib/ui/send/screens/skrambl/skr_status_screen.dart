import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skr_status_complete.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/solana/send_skrambled_transaction.dart';
import 'package:skrambl_app/ui/send/helpers/status_result.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skr_status_complete_delayed.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skr_status_failed.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skr_status_processing.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana/solana.dart';

class SendStatusScreen extends StatefulWidget {
  final String localId;
  final String destination;
  final Uint8List? txBytes;
  final Uint8List? signature;
  final double amount;
  final Ed25519HDPublicKey podPDA;
  final bool isDelayed;

  // queue-only path
  final String? launchSig;
  final bool queueOnly;

  const SendStatusScreen({
    super.key,
    required this.localId,
    required this.destination,
    required this.amount,
    required this.podPDA,
    required this.txBytes,
    required this.signature,
    required this.isDelayed,
  }) : launchSig = null,
       queueOnly = false;

  //Retry straight to queue (has no signature or txBytes)
  const SendStatusScreen.queueOnly({
    super.key,
    required this.localId,
    required this.destination,
    required this.amount,
    required this.podPDA,
    required this.launchSig,
    required this.isDelayed,
  }) : txBytes = null,
       signature = null,
       queueOnly = true;

  @override
  State<SendStatusScreen> createState() => _SendStatusScreenState();
}

class _SendStatusScreenState extends State<SendStatusScreen> with TickerProviderStateMixin {
  bool _started = false;
  bool _isComplete = false;
  bool _isFailed = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  int? _durationSec;
  Pod? _latestPod;
  bool _isScheduled = false; //For delayed delivery only

  //bool _seenOnChain = false; // remember if we ever saw the account
  late final StreamSubscription _podRowSub;
  late final AnimationController _fadeController;
  late final TransactionStatusProvider _status;
  late final VoidCallback _statusListener;
  late final PodDao dao;

  @override
  void initState() {
    super.initState();

    // subscribe to the pod row and mirror to UI phases
    dao = context.read<PodDao>();

    // Wire provider listener for your internal send transitions (unchanged)
    _status = context.read<TransactionStatusProvider>();
    _statusListener = _onStatusProviderChange;
    _status.addListener(_statusListener);

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Set the active one for UI updates
      context.read<TransactionStatusProvider>().setActivePod(widget.localId);

      // Kick off the send as soon as the screen renders
      if (!_started) {
        _started = true;

        //If retrying the queue only or else send
        if (widget.queueOnly) {
          _retryQueueOnly();
        } else {
          _send();
        }
      }

      _podRowSub = dao.watchById(widget.localId).listen((pod) async {
        if (pod == null) return;
        _latestPod = pod;

        // Submitted and is a delayed delivery
        if (widget.isDelayed && pod.status == PodStatus.submitted.index) {
          _timer?.cancel();
          if (!_isScheduled) {
            setState(() => _isScheduled = true);
            if (!_fadeController.isAnimating && _fadeController.value == 0.0) {
              _fadeController.forward();
            }
          }
        }

        // If delivering to destination
        if (pod.status == PodStatus.delivering.index && _status.phase != TransactionPhase.delivering) {
          _status.setPhase(TransactionPhase.delivering);
        }

        // If completed / finalized
        if (pod.status == PodStatus.finalized.index && !_isComplete) {
          setState(() => _durationSec = pod.durationSeconds);
          _status.setPhase(TransactionPhase.completed);
        }

        // If failed
        if (pod.status == PodStatus.failed.index && !_isFailed) {
          _status.setPhase(TransactionPhase.failed);
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _status.clearActivePod(widget.localId);
    });
    _fadeController.dispose();
    _podRowSub.cancel();
    _timer?.cancel();
    _status.removeListener(_statusListener);
    super.dispose();
  }

  void _onStatusProviderChange() {
    switch (_status.phase) {
      case TransactionPhase.completed:
        _timer?.cancel();
        setState(() => _isComplete = true);
        _fadeController.forward();
        break;

      case TransactionPhase.failed:
        _timer?.cancel();
        setState(() => _isFailed = true);
        break;

      default:
        break;
    }
  }

  //Start elapsed timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  // On phase change
  void _onPhase(TransactionPhase phase) {
    context.read<TransactionStatusProvider>().setPhase(phase);
  }

  //Mark pod failed - this is absolute worst case.
  //Show
  Future<void> _onSendFailure() async {
    await dao.markFailed(id: widget.localId);
  }

  // SENDING PATH
  /// Sends the transaction
  /// Marks the pod db record as submitted
  /// Sends the pod to the queue for processing
  /// If queue successful, flips to scrambling phase
  Future<void> _send() async {
    final status = context.read<TransactionStatusProvider>();
    try {
      //Record the submitting time so we can calculate duration
      await dao.markSubmitting(id: widget.localId);

      // Long-running send; UI is already visible
      final txSig = await sendTransactionWithRetry(
        widget.txBytes!,
        widget.signature!,
        5,
        _onPhase,
        _onSendFailure,
      );

      // Persist submitted and record the real transaction signature
      await dao.markSubmitted(id: widget.localId, signature: txSig);

      //If delayed deposit, end here.
      //The listener will take care of the rest.
      if (widget.isDelayed) return;

      // Queue orchestration, then flip to scrambling
      final queued = await queueInstantPod(
        QueueInstantPodRequest(pod: widget.podPDA.toBase58(), signature: txSig),
      );
      if (queued) await dao.markSkrambling(id: widget.localId);

      //Always set the status to scrambling
      status.setPhase(TransactionPhase.scrambling);
    } catch (e, st) {
      skrLogger.e('Send failed on status screen: $e\n$st');
      if (!mounted) return;
      // Let parent flip to RESEND
      Navigator.pop(
        context,
        SendStatusResult.failed(localId: widget.localId, message: 'Submission failed. You can resend.'),
      );
    }
  }

  // If retrying the queue only.
  Future<void> _retryQueueOnly() async {
    final status = context.read<TransactionStatusProvider>();
    try {
      final ok = await queueInstantPod(
        QueueInstantPodRequest(
          pod: widget.podPDA.toBase58(),
          signature: widget.launchSig!, // already on chain
        ),
      );
      if (ok) {
        await dao.markSkrambling(id: widget.localId);
        status.setPhase(TransactionPhase.scrambling);
        // watcher will handle delivering/completed
        // End.
      } else {
        // bounce back so parent can show RESEND again
        if (!mounted) return;
        Navigator.pop(
          context,
          SendStatusResult.failed(
            localId: widget.localId,
            message: 'Failed to send skramble queue. Please try again.',
          ),
        );
      }
    } catch (e) {
      skrLogger.e('Queue retry failed: $e');
      if (!mounted) return;
      Navigator.pop(
        context,
        SendStatusResult.failed(
          localId: widget.localId,
          message: 'Failed to send skramble queue. Please try again.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //If delayed delivery and is complete then view completed delay view.
    if (widget.isDelayed && _isScheduled) {
      if (_latestPod == null) return const Center(child: CircularProgressIndicator());
      return CompleteDelayedView(pod: _latestPod!);
    }

    return PopScope(
      canPop: true, // allow back navigation when processing.
      child: Scaffold(
        body: Center(
          child: _isComplete
              ? CompletedStatusView(
                  amountSol: widget.amount,
                  destination: widget.destination,
                  signatureBase58: widget.launchSig ?? signatureToBase58(widget.signature!),
                  durationSec: _durationSec,
                  fallbackDurationSec: _latestPod?.durationSeconds ?? 0,
                  fadeController: _fadeController,
                )
              : _isFailed
              ? _buildFailedView()
              : _buildProcessingView(),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    final status = context.watch<TransactionStatusProvider>();
    return ProcessingStatusView(displayText: status.displayText, elapsedSeconds: _elapsedSeconds);
  }

  Widget _buildFailedView() {
    return FailedStatusView(
      elapsedSeconds: _elapsedSeconds,
      onRetry: () => Navigator.pop(context, SendStatusResult.failed(localId: widget.localId)),
    );
  }
}
