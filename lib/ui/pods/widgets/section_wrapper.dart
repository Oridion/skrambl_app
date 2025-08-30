import 'package:flutter/material.dart';

class SectionWrapper extends StatelessWidget {
  final String label;
  final Widget child;

  // Optional niceties
  final Widget? trailing;
  final EdgeInsets outerPadding;
  final EdgeInsets contentPadding;
  final EdgeInsets labelPadding;
  final Color? backgroundColor;
  final Color? borderColor;

  const SectionWrapper({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
    this.outerPadding = const EdgeInsets.only(bottom: 15),
    this.contentPadding = const EdgeInsets.fromLTRB(12, 7, 12, 20),
    this.labelPadding = const EdgeInsets.fromLTRB(12, 10, 0, 3),
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final bg = backgroundColor ?? theme.colorScheme.surface;
    final bdr = borderColor ?? Colors.black26;

    return Padding(
      padding: outerPadding,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: bdr),
        ),
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: labelPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: t.labelMedium?.copyWith(
                      color: Colors.black87,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (trailing != null) ...[const Spacer(), trailing!],
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
