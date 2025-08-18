import 'package:flutter/material.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/ui/pods/widgets/from_to_bar.dart';
import 'package:skrambl_app/ui/shared/relative_time.dart'; // for withOpacityCompat if you use it elsewhere
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart'; // for PodStatus

/// Professional header for the Pod details page.
/// - Left: Big SOL amount with subtle "SOL" unit
/// - Right: Status pill + live relative time
class PodHeaderCard extends StatelessWidget {
  final PodStatus status;
  final Color chipColor;
  final DateTime? draftedAt;
  final int lamports; // raw lamports
  final Pod pod;

  const PodHeaderCard({
    super.key,
    required this.status,
    required this.chipColor,
    required this.draftedAt,
    required this.lamports,
    required this.pod,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card
        Container(
          margin: const EdgeInsets.only(top: 14), // room for the overlapping pill
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDFDFDF), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Column(
            children: [
              const SizedBox(height: 6), // small spacer under the pill
              FromToBar(from: pod.creator, to: pod.destination, shorten: shortenPubkey),
              const SizedBox(height: 5),
              const Divider(color: Colors.black38),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _AmountBlock(solText: _solString(lamports), textTheme: t),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (draftedAt != null) ...[
                        const SizedBox(height: 6),
                        RelativeTimeListen(
                          time: draftedAt!,
                          style: t.bodyMedium?.copyWith(color: Colors.black),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Overlapping pill
        Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: const Offset(0, 26),
            child: _StatusPill(text: status.name.toUpperCase(), color: chipColor),
          ),
        ),
      ],
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
          offset: const Offset(0, -5), // x, y — move up 2px
          child: SolanaLogo(size: 11, useDark: true),
        ),
        SizedBox(width: 5),
        Text(
          amount,
          style: textTheme.displaySmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
            height: 1,
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacityCompat(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacityCompat(0.45)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
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
