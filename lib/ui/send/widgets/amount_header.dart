import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/providers/network_fee_provider.dart';
import 'package:skrambl_app/ui/send/widgets/glitch_header.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/colors.dart';

class AmountHeader extends StatelessWidget {
  final double? amount; // User-entered SOL
  final int delaySeconds; // Slider value
  final double Function(int) calcFee; // Returns privacy fee in SOL
  final double? solUsdPrice; // Optional USD conversion
  final bool loadingFees; // Whether privacy fee is still loading

  const AmountHeader({
    super.key,
    required this.amount,
    required this.delaySeconds,
    required this.calcFee,
    required this.solUsdPrice,
    required this.loadingFees,
  });

  @override
  Widget build(BuildContext context) {
    final amt = _clampNonNegative(amount ?? 0.0);
    final privacyFeeSol = _clampNonNegative(calcFee(delaySeconds));

    // Safe read of network fee from provider; coerce to a sane finite number
    final networkFeeSol = context.select<NetworkFeeProvider, double>(
      (p) => (p.fee / AppConstants.lamportsPerSol).toDouble(),
    );
    final netFee = (networkFeeSol.isFinite && networkFeeSol >= 0) ? networkFeeSol : 0.0;
    final hasAmount = amount != null && amount! > 0;
    final total = hasAmount ? amt + privacyFeeSol + netFee : 0.0;

    return GlitchHeader(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTIMATED TOTAL',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacityCompat(0.7), letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),

            // Big total with fade between changes
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
              child: Row(
                key: ValueKey('row_$delaySeconds'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, 4),
                    child: const SolanaLogo(size: 16, useDark: false, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  // Accessibility for screen readers
                  Semantics(
                    label: 'Estimated total in SOL',
                    value: formatSol(total, maxDecimals: 5),
                    child: Text(
                      formatSol(total, maxDecimals: 5),
                      key: ValueKey('total_${total.toStringAsFixed(9)}_$delaySeconds'),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Breakdown
            if (hasAmount) ...[
              const SizedBox(height: 2),
              if (loadingFees)
                Opacity(
                  opacity: 0.7,
                  child: const Text(
                    'Estimating fees…',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                )
              else
                Row(
                  children: [
                    Text(
                      '(${formatSol(amt)} + ${formatSol(privacyFeeSol)} privacy fee '
                      '+ network fee)',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    if (solUsdPrice != null)
                      Text(
                        '• ${_formatUsd(total, solUsdPrice!)}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacityCompat(0.75)),
                      ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  static double _clampNonNegative(double v) => v.isFinite && v > 0 ? v : (v.isFinite ? 0.0 : 0.0);

  static String _formatUsd(double sol, double price) {
    final v = sol * price;
    if (v <= 0) return '\$0';
    if (v >= 100) return '\$${v.toStringAsFixed(0)}';
    if (v >= 1) return '\$${v.toStringAsFixed(2)}';
    return '\$${v.toStringAsFixed(4)}';
  }
}
