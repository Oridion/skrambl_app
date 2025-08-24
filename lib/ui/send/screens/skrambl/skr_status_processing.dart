import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/send/widgets/scrambled_text.dart';

class ProcessingStatusView extends StatelessWidget {
  final String displayText;
  final int elapsedSeconds;

  const ProcessingStatusView({super.key, required this.displayText, required this.elapsedSeconds});

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
        ScrambledText(
          text: displayText,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const SizedBox(height: 10),
        Text("Elapsed: ${_formatTime(elapsedSeconds)}", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 40),
        const CircularProgressIndicator(),
      ],
    );
  }
}
