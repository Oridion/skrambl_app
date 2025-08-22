import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

class StatusChip extends StatelessWidget {
  final bool used;

  const StatusChip({super.key, required this.used});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bg = used
        ? Colors.red.withOpacityCompat(0.12)
        : t.colorScheme.surfaceContainerHighest.withOpacityCompat(0.6);
    final fg = used ? Colors.red.shade700 : t.colorScheme.onSurface.withOpacityCompat(0.75);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: used ? Colors.red.shade200 : Colors.black12, width: 1),
      ),
      child: Text(
        used ? 'USED' : 'UNUSED',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
