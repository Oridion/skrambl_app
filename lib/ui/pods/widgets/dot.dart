import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  final Color color;
  final bool filled;

  const Dot({super.key, required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.white,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
