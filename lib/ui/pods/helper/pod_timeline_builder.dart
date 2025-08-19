import 'package:flutter/material.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/pods/widgets/vertical_timeline.dart';
import 'package:skrambl_app/utils/formatters.dart';

List<TimelineItem> buildTimeline({
  required DateTime? draftedAt,
  required DateTime? submittedAt,
  required DateTime? finalizedAt,
  required PodStatus status,
  required Pod pod,
  required bool isSenderBurner,
  required bool isDestinationBurner,
}) {
  final items = <TimelineItem>[];
  String draftedDetails;
  if (pod.mode == 5) {
    draftedDetails = "Standard delivery drafted ";
  } else if (pod.mode == 0) {
    draftedDetails = "Skrambled immediate delivery drafted ";
    // fallback if other modes
  } else {
    draftedDetails = "Skrambled delayed delivery drafted ";
  }

  if (isSenderBurner) {
    draftedDetails += 'from burner wallet';
  } else {
    draftedDetails += 'from primary wallet';
  }

  if (isDestinationBurner) {
    draftedDetails += ' to burner wallet';
  } else {
    draftedDetails += ' to ${shortenPubkey(pod.destination)}';
  }

  items.add(
    TimelineItem(
      title: 'Drafted',
      subtitle: draftedDetails,
      color: Colors.grey,
      completed: draftedAt != null,
      time: draftedAt,
    ),
  );

  final d = pod.submitDuration;
  final submittedSubtitle = d == null
      ? 'Submitted to network'
      : 'Submitted to network (${formatDurationShort(d)})';

  items.add(
    TimelineItem(
      title: 'Submitted',
      subtitle: submittedSubtitle,
      color: Colors.blue,
      completed: submittedAt != null,
      time: submittedAt,
    ),
  );

  //Show this section for skrambled pods only
  if (pod.mode != 5) {}

  // If failed
  if (status == PodStatus.failed) {
    items.add(
      TimelineItem(
        title: 'Failed',
        subtitle: 'See logs for details',
        color: Colors.red,
        completed: true,
        time: null,
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
        completed: finalizedAt != null || status == PodStatus.finalized,
        time: finalizedAt,
      ),
    );
  }

  return items;
}
