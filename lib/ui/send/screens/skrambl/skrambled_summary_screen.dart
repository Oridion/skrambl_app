import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/send/widgets/summary_money_row.dart';
import 'package:skrambl_app/ui/send/widgets/summary_sec_title.dart';
import 'package:skrambl_app/ui/shared/divider.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';
import '../../../../models/send_form_model.dart';

class SkrambledSummaryScreen extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onBack; // optional, not shown in UI here
  final bool canResend;
  final bool isSubmitting;
  final SendFormModel formModel;
  final bool darkBg;

  const SkrambledSummaryScreen({
    super.key,
    required this.onSend,
    required this.onBack,
    required this.formModel,
    required this.canResend,
    required this.isSubmitting,
    this.darkBg = false,
  });

  String get delayText {
    final d = formModel.delaySeconds;
    if (d == 0) return 'Immediate';
    if (d < 60) return '$d sec';
    final min = (d / 60).round();
    return '$min min';
  }

  String _etaHint(int delaySeconds) {
    if (delaySeconds == 0) return 'ETA: ~instant after hop';
    final m = math.max(1, (delaySeconds / 60).round());
    return 'ETA: ~${m}m after launch';
  }

  @override
  Widget build(BuildContext context) {
    final destination = formModel.destinationWallet ?? '—';
    final amountSol = formModel.amount ?? 0;
    final feeSol = formModel.fee;
    final totalSol = (formModel.amount != null) ? (amountSol + feeSol) : null;
    final price = formModel.solUsdPrice; // nullable

    String usd(double sol) {
      if (price == null) return '—';
      final v = sol * price;
      return v >= 100 ? '\$${v.toStringAsFixed(0)}' : '\$${v.toStringAsFixed(2)}';
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bg = darkBg ? Colors.black : const Color.fromARGB(255, 230, 230, 230);
    final onBg = darkBg ? Colors.white : Colors.black;
    final onBgMuted = darkBg ? Colors.white70 : Colors.black54;
    final divider = darkBg ? Colors.white10 : const Color.fromARGB(43, 16, 16, 16);
    final chipBg = darkBg ? Colors.white10 : const Color.fromARGB(255, 5, 137, 23);

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.only(left: 8), // adjust px as needed
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review transaction',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: onBg,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Final check before you send',
                    style: theme.textTheme.bodySmall?.copyWith(color: onBgMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 17),

          // CARD
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: darkBg ? const Color(0xFF0E0E0E) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: divider, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacityCompat(darkBg ? 0.35 : 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(32, 26, 32, 26),
                child: Column(
                  children: [
                    SectionTitle('Destination', color: onBgMuted),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              destination,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: onBg,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DELAY
                    SectionTitle('Delay', color: onBgMuted),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Text(
                          delayText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: chipBg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _etaHint(formModel.delaySeconds),
                          style: theme.textTheme.bodySmall?.copyWith(color: onBgMuted),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // AMOUNT
                    SectionTitle('Transferring', color: onBgMuted),
                    const SizedBox(height: 8),
                    MoneyRow(
                      leftPrimary: formatSol(amountSol),
                      rightSubtle: price == null ? null : usd(amountSol),
                      primaryColor: onBg,
                      subtleColor: onBgMuted,
                    ),

                    _KVRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Estimated fee',
                      value: formatSol(feeSol),
                      hintRight: price == null ? null : usd(feeSol),
                      color: onBg,
                      hintColor: onBgMuted,
                      iconColor: onBgMuted,
                    ),

                    const SizedBox(height: 20),

                    // TOTAL
                    SectionTitle('Total (sending + fee)', color: onBgMuted),
                    const SizedBox(height: 12),
                    MoneyRow(
                      leftPrimary: totalSol == null ? '0' : formatSol(totalSol),
                      rightSubtle: (price == null || totalSol == null) ? null : usd(totalSol),
                      primaryColor: const Color.fromARGB(255, 0, 0, 0),
                      subtleColor: onBgMuted,
                      big: true,
                    ),

                    // PRICE PLACEHOLDER
                    if (price == null) ...[
                      const SizedBox(height: 10),
                      _PriceSkeleton(color: onBgMuted.withOpacityCompat(0.35)),
                    ],

                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Not including network fees',
                        style: theme.textTheme.bodySmall?.copyWith(color: onBgMuted),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MINI RISK NOTE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkBg ? Colors.white10 : cs.primary.withOpacityCompat(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: divider),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 16, color: onBgMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'SKRAMBLED adds separation in traceability. It does not guarantee anonymity.',
                              style: theme.textTheme.bodySmall?.copyWith(color: onBgMuted, height: 1.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // CTA
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBg ? Colors.white : Colors.black,
                  foregroundColor: darkBg ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: isSubmitting
                      ? const SizedBox(
                          key: ValueKey('spinner'),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          canResend ? 'RESEND TRANSACTION' : 'SEND SKRAMBLED',
                          key: const ValueKey('label'),
                          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ——— small building blocks ———

class _KVRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? hintRight;
  final Color color;
  final Color iconColor;
  final Color hintColor;
  const _KVRow({
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
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
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

class _PriceSkeleton extends StatefulWidget {
  final Color color;
  const _PriceSkeleton({required this.color});
  @override
  State<_PriceSkeleton> createState() => _PriceSkeletonState();
}

class _PriceSkeletonState extends State<_PriceSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _fade = Tween(
    begin: 0.35,
    end: 0.85,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: 10,
          width: 80,
          decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}
