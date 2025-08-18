import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/utils/duration.dart';
import 'package:skrambl_app/utils/solana.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/solana/send_skrambled_transaction.dart';
import 'package:skrambl_app/ui/root_shell.dart';
import 'package:skrambl_app/ui/send/helpers/status_result.dart';
import 'package:skrambl_app/ui/send/widgets/scrambled_text.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart';
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
  }) : launchSig = null,
       queueOnly = false;

  const SendStatusScreen.queueOnly({
    super.key,
    required this.localId,
    required this.destination,
    required this.amount,
    required this.podPDA,
    required this.launchSig,
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
  Timer? _podWatcher;
  int? _durationSec;
  late Pod _latestPod;

  //bool _seenOnChain = false; // remember if we ever saw the account
  late final StreamSubscription _podRowSub;
  late final AnimationController _fadeController;
  late final TransactionStatusProvider _status;
  late final VoidCallback _statusListener;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Kick off the send as soon as the screen renders
      if (!_started) {
        _started = true;
        if (widget.queueOnly) {
          _retryQueueOnly(); // <— new
        } else {
          _send(); // existing send path
        }
      }

      // Wire provider listener for your internal send transitions (unchanged)
      _status = context.read<TransactionStatusProvider>();
      _statusListener = _onStatusProviderChange;
      _status.addListener(_statusListener);

      // subscribe to the pod row and mirror to UI phases
      final dao = context.read<PodDao>();
      _podRowSub = dao.watchById(widget.localId).listen((pod) async {
        if (pod == null) return;
        _latestPod = pod;

        // Delivering: when your backend flips the process or when status changes
        if (pod.status == PodStatus.delivering.index) {
          if (_status.phase != TransactionPhase.delivering) {
            _status.setPhase(TransactionPhase.delivering);
          }
        }

        // Completed
        if (pod.status == PodStatus.finalized.index) {
          _timer?.cancel();
          if (!_isComplete) {
            final dur = pod.durationSeconds; // non-null with your current schema

            setState(() {
              _durationSec = dur;
              _isComplete = true;
            });
            _fadeController.forward();
          }
        }

        // Failed
        if (pod.status == PodStatus.failed.index) {
          if (!_isFailed) {
            setState(() {
              _isFailed = true;
              _timer?.cancel();
            });
          }
        }
      });
    });
  }

  void _onStatusProviderChange() {
    switch (_status.phase) {
      case TransactionPhase.scrambling:
        // No local watcher here anymore — global manager handles it
        break;
      case TransactionPhase.delivering:
        break;
      case TransactionPhase.completed:
        setState(() {
          _isComplete = true;
          _timer?.cancel();
        });
        _fadeController.forward();
        break;
      case TransactionPhase.failed:
        setState(() {
          _isFailed = true;
          _timer?.cancel();
        });
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _podRowSub.cancel();
    _timer?.cancel();
    // remove the listener to avoid leaks
    try {
      _status.removeListener(_statusListener);
    } catch (_) {}
    _podWatcher?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return "$m:$sec";
  }

  void _onPhase(TransactionPhase phase) {
    context.read<TransactionStatusProvider>().setPhase(phase);
  }

  Future<void> _retryQueueOnly() async {
    final dao = context.read<PodDao>();
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
      } else {
        // bounce back so parent can show RESEND again
        if (!mounted) return;
        Navigator.pop(
          context,
          SendStatusResult.failed(localId: widget.localId, message: 'Queue failed. Try again.'),
        );
      }
    } catch (e) {
      skrLogger.e('Queue retry failed: $e');
      if (!mounted) return;
      Navigator.pop(
        context,
        SendStatusResult.failed(localId: widget.localId, message: 'Queue failed. Try again.'),
      );
    }
  }

  // SENDING PATH
  /// Sends the transaction
  /// Marks the pod db record as submitted
  /// Sends the pod to the queue for processing
  /// If queue successful, flips to scrambling phase
  Future<void> _send() async {
    final dao = context.read<PodDao>();
    final status = context.read<TransactionStatusProvider>();
    try {
      //Record the submitting time so we can calculate duration
      await dao.markSubmitting(id: widget.localId);

      // Long-running send; UI is already visible
      final txSig = await sendTransactionWithRetry(widget.txBytes!, widget.signature!, 5, _onPhase);

      // Persist submitted and record the real transaction signature
      await dao.markSubmitted(id: widget.localId, signature: txSig);

      // Queue orchestration, then flip to scrambling
      final queued = await queueInstantPod(
        QueueInstantPodRequest(pod: widget.podPDA.toBase58(), signature: txSig),
      );
      if (queued) {
        await dao.markSkrambling(id: widget.localId);
      }
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // allow back navigation when processing.
      child: Scaffold(
        body: Center(
          child: _isComplete
              ? _buildCompletedView()
              : _isFailed
              ? _buildFailedView()
              : _buildProcessingView(),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    final status = context.watch<TransactionStatusProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScrambledText(
          text: status.displayText,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 10),
        Text("Elapsed: ${_formatTime(_elapsedSeconds)}", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 40),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildFailedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        const Text("Transaction Failed", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Elapsed: ${_formatTime(_elapsedSeconds)}", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, SendStatusResult.failed(localId: widget.localId)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text("Go Back & Retry"),
        ),
      ],
    );
  }

  Widget _buildCompletedView() {
    final amountStr = '${widget.amount} SOL';
    final sigBase58 = widget.launchSig ?? signatureToBase58(widget.signature!);

    return FadeTransition(
      opacity: _fadeController.drive(CurveTween(curve: Curves.easeOut)),
      child: Stack(
        children: [
          // Subtle success gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 217, 230, 221), // light mint
                  Color.fromARGB(255, 211, 225, 214), // almost white
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated success badge
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                        child: Container(
                          height: 92,
                          width: 92,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacityCompat(0.10),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green.withOpacityCompat(0.25), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacityCompat(0.18),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded, size: 48, color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        'Delivered',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your SKRAMBL transfer has finalized.',
                        style: TextStyle(fontSize: 14.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      // Receipt card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(36, 36, 36, 28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacityCompat(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black38),
                          boxShadow: const [
                            BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Amount row
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AMOUNT', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(2, 8), // x, y — move up 2px
                                      child: SolanaLogo(size: 12, useDark: true),
                                    ),
                                    const SizedBox(width: 13),
                                    Text(
                                      amountStr,
                                      style: const TextStyle(fontSize: 18.5, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Destination row (copyable)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'DESTINATION',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      size: 18,
                                      color: Colors.black87,
                                    ),

                                    const SizedBox(width: 8),
                                    SelectableText(
                                      _ellipsize(widget.destination, head: 8, tail: 8),
                                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: 'Copy address',
                                      icon: const Icon(Icons.copy_rounded, size: 18),
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(text: widget.destination));
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Address copied'),
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(milliseconds: 1200),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SIGNATURE',
                                  style: TextStyle(fontSize: 13, color: Colors.black54),
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      size: 18,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 8),
                                    SelectableText(
                                      _ellipsize(signatureToBase58(widget.signature!), head: 8, tail: 8),
                                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                                    ),

                                    const SizedBox(width: 8),

                                    IconButton(
                                      tooltip: 'View on SolanaFM',
                                      icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                                      onPressed: () => openOnSolanaFM(context, sigBase58),
                                    ),

                                    // IconButton(
                                    //   tooltip: 'Copy address',
                                    //   icon: const Icon(Icons.copy_rounded, size: 18),
                                    //   onPressed: () async {
                                    //     await Clipboard.setData(
                                    //       ClipboardData(text: signatureToBase58(widget.signature!)),
                                    //     );
                                    //     if (!mounted) return;
                                    //     ScaffoldMessenger.of(context).showSnackBar(
                                    //       const SnackBar(
                                    //         content: Text('Address copied'),
                                    //         behavior: SnackBarBehavior.floating,
                                    //         duration: Duration(milliseconds: 1200),
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                  ],
                                ),

                                // Duration row
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'DURATION',
                                      style: TextStyle(fontSize: 13, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded, size: 18, color: Colors.black87),
                                        const SizedBox(width: 10),
                                        Text(
                                          formatDurationHMS(_durationSec ?? _latestPod.durationSeconds),
                                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<WalletBalanceProvider>().refresh();

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 0)),
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black26),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),

                            label: const Text('Done'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<WalletBalanceProvider>().refresh();
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              ); // back one: returns to amount/summary step
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.autorenew_rounded, size: 18),
                            label: const Text('Send another'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      // Tiny footnote (optional)
                      const Text(
                        'Balances will refresh shortly after confirmation.',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Safe ellipsize for long keys
  String _ellipsize(String s, {int head = 6, int tail = 6}) {
    if (s.length <= head + tail + 1) return s;
    return '${s.substring(0, head)}…${s.substring(s.length - tail)}';
  }
}
