import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const SectionTitle(this.text, {super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 236, 236),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w800, letterSpacing: 1.3),
      ),
    );
  }
}
