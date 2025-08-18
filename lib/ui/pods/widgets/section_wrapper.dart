import 'package:flutter/material.dart';

class SectionWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  const SectionWrapper({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(14, 10, 0, 0),
                  child: Text(
                    label,
                    style: t.labelMedium?.copyWith(
                      color: Colors.black87,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
