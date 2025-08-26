import 'package:flutter/material.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/shared/relative_time.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class PodCard extends StatelessWidget {
  final Pod pod;
  final VoidCallback? onTap;

  const PodCard({super.key, required this.pod, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Cache theme/lookups
    final theme = Theme.of(context);
    final t = theme.textTheme;

    // Precompute once
    final status = PodStatus.values[pod.status];
    final chip = switch (status) {
      PodStatus.drafting => Colors.grey,
      PodStatus.launching => Colors.blueGrey,
      PodStatus.submitted => Colors.blue,
      PodStatus.scrambling => Colors.deepPurple,
      PodStatus.delivering => Colors.orange,
      PodStatus.finalized => Colors.green,
      PodStatus.failed => Colors.red,
    };

    final isDestBurner = pod.isDestinationBurner;
    final destColor = isDestBurner ? AppConstants.burnerColor : (t.bodyMedium?.color);
    final draftedAt = DateTime.fromMillisecondsSinceEpoch(pod.draftedAt * 1000);

    final amountSol = pod.lamports / AppConstants.lamportsPerSol;
    final amountStr = formatSol(amountSol, maxDecimals: 6); // avoids long doubles

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      clipBehavior: Clip.antiAlias, // cheaper paints on complex children
      child: ListTile(
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Don’t let the ticking time force the whole tile to repaint
            RepaintBoundary(
              child: RelativeTimeListen(time: draftedAt, style: t.titleSmall),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Transform.translate(offset: Offset(0, 1), child: SolanaLogo(size: 8, useDark: true)),
                SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '$amountStr to ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium,
                  ),
                ),

                if (isDestBurner) ...[
                  Icon(Icons.local_fire_department, size: 18, color: AppConstants.burnerColor),
                  const SizedBox(width: 2),
                ],

                Flexible(
                  child: Text(
                    shortenPubkey(pod.destination),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium?.copyWith(color: destColor),
                  ),
                ),
              ],
            ),
          ],
        ),

        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: chip.withOpacityCompat(.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: chip.withOpacityCompat(.35)),
          ),
          child: Text(
            status.name.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: chip),
          ),
        ),

        onTap: onTap,
      ),
    );
  }
}
