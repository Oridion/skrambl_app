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
          colors: [
            Color.fromARGB(255, 30, 30, 30),
            Color.fromARGB(255, 59, 59, 59),
            Color.fromARGB(255, 61, 61, 61),
          ],
        ),
      ),
      child: child,
    );
  }
}
