import 'package:flutter/material.dart';

class GlitchHeader extends StatelessWidget {
  final Widget child;

  const GlitchHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C2D), Color(0xFF2E2B40), Color(0xFF444160)],
        ),
      ),
      child: child,
    );
  }
}
