import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/solana/send_skrambled_transaction.dart';
import 'package:skrambl_app/ui/dashboard/dashboard_screen.dart';
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

        // Delivering: when your backend flips the process or when status changes
        if (pod.status == PodStatus.delivering.index) {
          if (_status.phase != TransactionPhase.delivering) {
            _status.setPhase(TransactionPhase.delivering);
          }
        }

        // Completed
        if (pod.status == PodStatus.finalized.index) {
          if (!_isComplete) {
            setState(() {
              _isComplete = true;
              _timer?.cancel();
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacityCompat(0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black38),
                          boxShadow: const [
                            BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Amount row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //const Icon(Icons.send_rounded, size: 18, color: Colors.black87),
                                Transform.translate(
                                  offset: const Offset(3, 3), // x, y — move up 2px
                                  child: SolanaLogo(size: 12, useDark: true),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Amount',
                                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        amountStr,
                                        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Destination row (copyable)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Destination',
                                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                                      ),
                                      const SizedBox(height: 6),
                                      SelectableText(
                                        _ellipsize(widget.destination, head: 8, tail: 8),
                                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
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

                            const SizedBox(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Signature',
                                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                                      ),
                                      const SizedBox(height: 6),
                                      SelectableText(
                                        _ellipsize(signatureToBase58(widget.signature!), head: 8, tail: 8),
                                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Copy address',
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: signatureToBase58(widget.signature!)),
                                    );
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
                                MaterialPageRoute(builder: (_) => const Dashboard()),
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
