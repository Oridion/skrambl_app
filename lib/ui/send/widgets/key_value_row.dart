import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';

/// A compact key–value row with a leading icon, label on the left,
/// and a SOL-value + optional hint on the right.
///
/// Example:
/// KVRow(
///   icon: Icons.lock_clock_rounded,
///   label: 'Privacy fee',
///   value: '0.003210',
///   hintRight: '\$0.54',
///   color: Colors.black87,
///   iconColor: Colors.black87,
///   hintColor: Colors.black45,
/// )
class KVRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? hintRight;
  final Color color;
  final Color iconColor;
  final Color hintColor;

  const KVRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
    required this.hintColor,
    this.hintRight,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: t.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w300),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SolanaLogo(size: 8, color: color),
                ),
                const SizedBox(width: 3),
                Text(
                  value,
                  style: t.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            if (hintRight != null) Text(hintRight!, style: t.bodySmall?.copyWith(color: hintColor)),
          ],
        ),
      ],
    );
  }
}
