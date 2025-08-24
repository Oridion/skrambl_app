import 'package:flutter/material.dart';

class FailedStatusView extends StatelessWidget {
  final int elapsedSeconds;
  final VoidCallback onRetry;

  const FailedStatusView({super.key, required this.elapsedSeconds, required this.onRetry});

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return "$m:$sec";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        const Text("Transaction Failed", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Elapsed: ${_formatTime(elapsedSeconds)}", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onRetry,
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
}
