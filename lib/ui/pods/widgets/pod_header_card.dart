import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/shared/relative_time.dart'; // for withOpacityCompat if you use it elsewhere
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart'; // for PodStatus

/// Professional header for the Pod details page.
/// - Left: Big SOL amount with subtle "SOL" unit
/// - Right: Status pill + live relative time
class PodHeaderCard extends StatelessWidget {
  final PodStatus status;
  final Color chipColor;
  final DateTime? draftedAt;
  final int lamports; // raw lamports

  const PodHeaderCard({
    super.key,
    required this.status,
    required this.chipColor,
    required this.draftedAt,
    required this.lamports,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(255, 223, 223, 223), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Amount (prominent)
          Expanded(
            child: _AmountBlock(solText: _solString(lamports), textTheme: t),
          ),

          const SizedBox(width: 12),

          // Status + time (compact, right-aligned)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusPill(text: status.name.toUpperCase(), color: chipColor),
              if (draftedAt != null) ...[
                const SizedBox(height: 6),
                // live “time since created”
                RelativeTimeListen(
                  time: draftedAt!,
                  style: t.bodySmall?.copyWith(color: Colors.black),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Big amount with small SOL unit; uses tabular figures for stability.
class _AmountBlock extends StatelessWidget {
  final String solText;
  final TextTheme textTheme;
  const _AmountBlock({required this.solText, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final parts = solText.split(' ');
    final amount = parts.first; // e.g. 12.3456
    final unit = parts.length > 1 ? parts[1] : 'SOL';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        Transform.translate(
          offset: const Offset(0, -7), // x, y — move up 2px
          child: SolanaLogo(size: 14, useDark: true),
        ),
        SizedBox(width: 7),
        Text(
          amount,
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.0,
            height: 1.0,
            color: Colors.black,
            // Use monospace digits to avoid jitter if your font supports it
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(width: 3),
        Text(unit, style: textTheme.labelLarge?.copyWith(color: Colors.black, letterSpacing: 0.3)),
      ],
    );
  }
}

/// Compact status chip with strong contrast and tight letter-spacing.
class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacityCompat(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacityCompat(0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ).copyWith(color: color),
      ),
    );
  }
}

/// Convert lamports → SOL string without trailing zeros, e.g. "12.34 SOL"
String _solString(int lamports) {
  const lamportsPerSol = 1000000000; // 1e9
  final sol = lamports / lamportsPerSol;
  // Keep up to 6 decimals, then trim trailing zeros
  var s = sol.toStringAsFixed(6);
  s = s.contains('.') ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '') : s;
  return '$s SOL';
}
