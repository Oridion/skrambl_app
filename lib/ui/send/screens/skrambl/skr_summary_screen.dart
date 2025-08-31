import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/network_fee_provider.dart';
import 'package:skrambl_app/ui/send/helpers/hop_estimator.dart';
import 'package:skrambl_app/ui/send/widgets/price_skeleton.dart';
import 'package:skrambl_app/ui/send/widgets/summary_money_row.dart';
import 'package:skrambl_app/ui/send/widgets/summary_sec_title.dart';
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

  String get delayText => getDelayText(formModel.delaySeconds);

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
    final divider = darkBg ? Colors.white10 : const Color.fromARGB(43, 0, 0, 0);
    final chipBg = darkBg ? Colors.white10 : const Color.fromARGB(255, 62, 62, 62);
    final networkFeeLamports = context.select<NetworkFeeProvider, int>((p) => p.fee);

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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: divider, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacityCompat(darkBg ? 0.35 : 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
                child: Column(
                  children: [
                    SectionTitle('Destination', color: onBgMuted),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: SelectableText(
                        shortenPubkey(destination, length: 10),
                        style: theme.textTheme.bodyMedium?.copyWith(color: onBg, fontWeight: FontWeight.w400),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DELAY
                    SectionTitle('Delay', color: onBgMuted),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Text(
                          delayText.toUpperCase(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: chipBg,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ETA: ${getETAText(formModel.delaySeconds)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: onBgMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '~${estimateHops(formModel.delaySeconds)} hops',
                          style: theme.textTheme.bodySmall?.copyWith(color: onBgMuted),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // AMOUNT
                    SectionTitle('Transferring', color: onBgMuted),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          MoneyRow(
                            leftPrimary: 'Sending amount',
                            solAmount: formatSol(amountSol),
                            primaryColor: chipBg,
                            subtleColor: chipBg,
                          ),
                          SizedBox(height: 3),
                          MoneyRow(
                            leftPrimary: 'Privacy Fee',
                            solAmount: formatSol(feeSol),
                            primaryColor: chipBg,
                            subtleColor: chipBg,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TOTAL
                    SectionTitle('Total', color: onBgMuted),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: const EdgeInsets.only(top: 16), child: SolanaLogo(size: 13)),
                          const SizedBox(width: 6),
                          Text(
                            formatSol(totalSol!, maxDecimals: 7),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4),
                    Text('(${usd(totalSol)})', style: TextStyle(color: Colors.black54, fontSize: 14)),
                    SizedBox(height: 6),

                    // PRICE PLACEHOLDER
                    if (price == null) ...[
                      const SizedBox(height: 10),
                      PriceSkeleton(color: onBgMuted.withOpacityCompat(0.35)),
                    ],

                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '+ Network fee (~$networkFeeLamports lamports)',
                        style: theme.textTheme.bodySmall?.copyWith(color: onBgMuted),
                      ),
                    ),

                    const SizedBox(height: 26),

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
