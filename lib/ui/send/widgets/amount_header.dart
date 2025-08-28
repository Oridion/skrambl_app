import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/send/widgets/glitch_header.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/colors.dart';

class AmountHeader extends StatelessWidget {
  /// Already-computed values from the parent.
  final double totalSol; // REQUIRED: amount + privacy (no network fee here)
  final double? amountSol; // OPTIONAL: for the breakdown
  final double? privacyFeeSol; // OPTIONAL: for the breakdown
  final bool loadingFees; // if true, show "Estimating privacy fee…"
  final double? solUsdPrice; // OPTIONAL: USD conversion

  const AmountHeader({
    super.key,
    required this.totalSol,
    this.amountSol,
    this.privacyFeeSol,
    required this.loadingFees,
    this.solUsdPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Defensive formatting (no business logic)
    final amt = _nz(amountSol);
    final fee = privacyFeeSol == null ? null : _nz(privacyFeeSol);
    final hasAmount = amountSol != null && amt > 0;
    final total = hasAmount ? _nz(totalSol) : 0.0;
    final totalKey = total.toStringAsFixed(9);

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

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
              child: Row(
                key: ValueKey(totalKey),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: Offset(0, 4),
                    child: const SolanaLogo(size: 16, useDark: false, color: Colors.white),
                  ),

                  const SizedBox(width: 8),
                  Semantics(
                    label: 'Estimated total in SOL',
                    value: formatSol(total, maxDecimals: 6),
                    child: Text(
                      formatSol(total, maxDecimals: 6),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            if (hasAmount) ...[
              const SizedBox(height: 2),
              if (loadingFees || fee == null)
                const Opacity(
                  opacity: 0.75,
                  child: Text(
                    'Estimating privacy fee…',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                )
              else
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${formatSol(amt)} + ${formatSol(fee)} privacy fee',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_hasUsd(solUsdPrice))
                      Text(
                        '=  ${_formatUsd(total, solUsdPrice!)} USD',
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

  static double _nz(double? v) {
    if (v != null && v.isFinite && v > 0) return v;
    return 0.0;
  }

  static bool _hasUsd(double? p) => p != null && p.isFinite && p > 0;

  static String _formatUsd(double sol, double price) {
    final v = sol * price;
    if (v <= 0) return '\$0';
    if (v >= 100) return '\$${v.toStringAsFixed(0)}';
    if (v >= 1) return '\$${v.toStringAsFixed(2)}';
    return '\$${v.toStringAsFixed(4)}';
  }
}
