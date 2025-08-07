// lib/ui/send/screens/send_status_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/ui/send/widgets/scrambled_text.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

class SendStatusScreen extends StatefulWidget {
  final String destination;
  final double amount;
  final Ed25519HDPublicKey podPDA;

  const SendStatusScreen({
    super.key,
    required this.destination,
    required this.amount,
    required this.podPDA,
  });

  @override
  State<SendStatusScreen> createState() => _SendStatusScreenState();
}

class _SendStatusScreenState extends State<SendStatusScreen>
    with TickerProviderStateMixin {
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isComplete = false;
  bool _isFailed = false;

  late AnimationController _fadeController;
  //late Animation<Color?> _bgColorTween;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // _bgColorTween =
    //     ColorTween(
    //       begin: Colors.transparent,
    //       end: const Color.fromARGB(255, 169, 238, 205).withAlpha(3),
    //     ).animate(
    //       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    //     );

    _startTimer();

    // Watch provider for status changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final statusProvider = Provider.of<TransactionStatusProvider>(
        context,
        listen: false,
      );

      statusProvider.addListener(() {
        if (statusProvider.phase == TransactionPhase.failed) {
          setState(() {
            _isFailed = true;
            _timer?.cancel();
          });
        }

        if (statusProvider.phase == TransactionPhase.scrambling) {
          // Start polling for closure
          skrLogger.i("Starting to listen for pod updates");
          _pollForPodClosure(widget.podPDA.toString());
        } else if (statusProvider.phase == TransactionPhase.completed) {
          setState(() {
            _isComplete = true;
            _timer?.cancel();
          });
          _fadeController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  Future<void> _pollForPodClosure(String podPubkey) async {
    final rpcClient = RpcClient(
      "https://bernette-tb3sav-fast-mainnet.helius-rpc.com",
    );
    skrLogger.i(podPubkey);
    final statusProvider = Provider.of<TransactionStatusProvider>(
      context,
      listen: false,
    );

    await Future.delayed(Duration(seconds: 5));

    bool hasEverExisted = false;

    while (mounted) {
      try {
        final accountInfo = await rpcClient.getAccountInfo(
          podPubkey,
          encoding: Encoding.base64,
        );

        if (accountInfo.value != null) {
          //skrLogger.i("Pod found!");
          hasEverExisted = true; // We've seen it on-chain
        } else if (hasEverExisted) {
          // It existed before, now it's gone → closed!
          skrLogger.i("✅ Pod closed! Delivery complete!");
          statusProvider.setPhase(TransactionPhase.completed);
          break;
        }
      } catch (_) {
        if (hasEverExisted) {
          skrLogger.i("✅ Pod closed (RPC error caught)!");
          statusProvider.setPhase(TransactionPhase.completed);
          break;
        }
      }

      //skrLogger.i("Still waiting...");
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _isComplete,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            //AnimatedBackground(isActive: !_isComplete),
            Center(
              child: _isComplete
                  ? _buildCompletedView()
                  : _isFailed
                  ? _buildFailedView()
                  : _buildDeliveringView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        const Text(
          "Transaction Failed",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Elapsed: ${_formatTime(_elapsedSeconds)}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Go back to retry
          },
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

  Widget _buildDeliveringView() {
    final statusProvider = Provider.of<TransactionStatusProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScrambledText(
          text: statusProvider.displayText,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Elapsed: ${_formatTime(_elapsedSeconds)}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 40),
        const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildCompletedView() {
    return Container(
      color: const Color.fromARGB(
        255,
        97,
        186,
        120,
      ).withAlpha(60), // 👈 light green background
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              "Delivered!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Sent ${widget.amount} SOL to"),
            const SizedBox(height: 6),
            Text(
              widget.destination,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 52),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("BACK TO DASHBOARD"),
            ),
          ],
        ),
      ),
    );
  }
}
