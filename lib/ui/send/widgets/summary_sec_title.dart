import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const SectionTitle(this.text, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w800, letterSpacing: 0.9),
    );
  }
}
