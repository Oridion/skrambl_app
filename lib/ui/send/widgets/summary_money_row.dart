import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';

class MoneyRow extends StatelessWidget {
  final String leftPrimary;
  final String solAmount;
  final String? rightSubtle;

  final Color primaryColor;
  final Color subtleColor;

  const MoneyRow({
    super.key,
    required this.leftPrimary,
    required this.solAmount,
    required this.primaryColor,
    required this.subtleColor,
    this.rightSubtle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(leftPrimary, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))],
        ),

        Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: SolanaLogo(size: 8, color: primaryColor),
                ),
                const SizedBox(width: 1),
                Text(
                  solAmount,
                  style: (t.bodyMedium)?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
