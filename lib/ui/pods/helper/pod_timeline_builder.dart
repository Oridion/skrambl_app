import 'package:flutter/material.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/models/timeline_item.dart';
import 'package:skrambl_app/ui/pods/widgets/count_down.dart';
import 'package:skrambl_app/utils/formatters.dart';

List<TimelineItem> buildTimeline({required Pod pod}) {
  final items = <TimelineItem>[];

  //skrLogger.i("pod.submittedAt ${pod.submittedAt}");

  final status = PodStatus.values[pod.status];
  final draftedAt = dateTimeOrNull(pod.draftedAt);
  final submittedAt = dateTimeOrNullSeconds(pod.submittedAt);
  final skrambledAt = dateTimeOrNullSeconds(pod.skrambledAt);
  final finalizedAt = dateTimeOrNullSeconds(pod.finalizedAt);
  final d = pod.submitDuration;
  final submittedSubtitle = d == null
      ? 'Submitted to network'
      : 'Submitted to network (${formatDurationShort(d)})';

  String draftedDetails;
  if (pod.mode == 5) {
    draftedDetails = "Standard delivery drafted ";
  } else if (pod.mode == 0) {
    draftedDetails = "Skrambled immediate delivery drafted ";
    // fallback if other modes
  } else {
    draftedDetails = "Skrambled delayed delivery drafted ";
  }

  if (pod.isCreatorBurner) {
    draftedDetails += 'from burner wallet';
  } else {
    draftedDetails += 'from primary wallet';
  }

  if (pod.isDestinationBurner) {
    draftedDetails += ' to burner wallet';
  } else {
    draftedDetails += ' to ${shortenPubkey(pod.destination)}';
  }

  items.add(
    TimelineItem(
      title: 'Drafted',
      subtitle: draftedDetails,
      color: Colors.grey,
      isActive: draftedAt == null,
      at: draftedAt,
    ),
  );

  items.add(
    TimelineItem(
      title: 'Submitted',
      subtitle: submittedSubtitle,
      color: Colors.blue,
      isActive: submittedAt == null,
      at: submittedAt,
    ),
  );

  //Show this section for delayed skrambled pods only
  if (pod.mode == 1) {
    items.add(
      TimelineItem(
        title: 'Skrambling',
        subtitle: 'Hopping through Oridion',
        countdownWidget: skrambledAt != null
            ? null
            : TimelineCountdownToEta(
                key: ValueKey('eta:${pod.id}:${pod.submittedAt}:${pod.delaySeconds}'),
                submittedAt: submittedAt!,
                delaySeconds: pod.delaySeconds,
                style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w400),
              ),
        color: Colors.purple,
        isActive: submittedAt == null,
        at: submittedAt,
      ),
    );
  }

  //Show delivering timeline tile
  if (skrambledAt != null) {
    items.add(
      TimelineItem(
        title: 'Delivering',
        subtitle: 'Delivering to destination',
        color: Colors.blue,
        isActive: false,
        at: skrambledAt,
      ),
    );
  }

  // If failed
  if (status == PodStatus.failed) {
    items.add(
      TimelineItem(
        title: 'Failed',
        subtitle: 'See logs for details',
        color: Colors.red,
        isActive: true,
        at: null,
      ),
    );
  }

  // If finalized
  if (status == PodStatus.finalized) {
    items.add(
      TimelineItem(
        title: 'Finalized',
        subtitle: 'Delivery to ${shortenPubkey(pod.destination)} completed successfully and finalized',
        color: Colors.green,
        isActive: finalizedAt != null || status == PodStatus.finalized,
        at: finalizedAt,
      ),
    );
  }

  return items;
}
