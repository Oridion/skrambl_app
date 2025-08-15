import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';

class MoneyRow extends StatelessWidget {
  final String leftPrimary;
  final String? rightSubtle;
  final bool big;
  final Color primaryColor;
  final Color subtleColor;

  const MoneyRow({
    super.key,
    required this.leftPrimary,
    required this.primaryColor,
    required this.subtleColor,
    this.rightSubtle,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SolanaLogo(size: big ? 10 : 8, color: primaryColor),
            ),
            const SizedBox(width: 3),
            Text(
              leftPrimary,
              style: (big ? t.titleLarge : t.titleMedium)?.copyWith(
                color: primaryColor,
                fontWeight: big ? FontWeight.w900 : FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        if (rightSubtle != null) Text(rightSubtle!, style: t.bodyMedium?.copyWith(color: subtleColor)),
      ],
    );
  }
}
