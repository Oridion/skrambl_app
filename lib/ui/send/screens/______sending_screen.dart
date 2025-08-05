import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/logger.dart';

class SendingScreen extends StatefulWidget {
  final Future<String> Function()? onSend;

  const SendingScreen({super.key, this.onSend});

  @override
  State<SendingScreen> createState() => _SendingScreenState();
}

class _SendingScreenState extends State<SendingScreen> {
  bool _isSending = true;
  String? _txSig;

  @override
  void initState() {
    super.initState();
    _startSending();
  }

  Future<void> _startSending() async {
    try {
      if (widget.onSend != null) {
        final sig = await widget.onSend!();
        setState(() {
          _isSending = false;
          _txSig = sig;
        });
      }
    } catch (e) {
      skrLogger.e('[SKRAMBL] Transaction failed: $e');
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSending)
                  const SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 80,
                  ),
                const SizedBox(height: 32),
                Text(
                  _isSending
                      ? 'Sending your SKRAMBL...'
                      : 'Transaction complete!',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_txSig != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _txSig!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                if (!_isSending)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('Return to Dashboard'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
