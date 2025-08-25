// lib/ui/pods/widgets/pod_card.dart
import 'package:flutter/material.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/shared/relative_time.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class PodCard extends StatelessWidget {
  final Pod pod;
  final VoidCallback? onTap;

  const PodCard({super.key, required this.pod, this.onTap});

  @override
  Widget build(BuildContext context) {
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RelativeTimeListen(
              time: DateTime.fromMillisecondsSinceEpoch(pod.draftedAt * 1000),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${pod.lamports / AppConstants.lamportsPerSol} to ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                //If burner add icon here.
                if (pod.isDestinationBurner) ...[
                  Icon(Icons.local_fire_department, color: AppConstants.burnerColor, size: 18),
                  const SizedBox(width: 2),
                ],

                //If burner address turn color to burner red color
                // Destination address with conditional color
                Text(
                  shortenPubkey(pod.destination),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: pod.isDestinationBurner
                        ? AppConstants.burnerColor
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ), // <-- margin between title and subtitle
          ],
        ),
        //   '${pod.lamports / 1000000000} to ${shortenPubkey(pod.destination)}',
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
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
