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
}) {
  final items = <TimelineItem>[];
  String draftedDetails;
  if (pod.mode == 5) {
    draftedDetails = "Standard delivery drafted";
  } else if (pod.mode == 0) {
    draftedDetails = "Skrambled immediate delivery drafted";
    // fallback if other modes
  } else {
    draftedDetails = "Skrambled delayed delivery drafted";
  }

  items.add(
    TimelineItem(
      title: 'Drafted',
      subtitle: '$draftedDetails for delievery',
      color: Colors.grey,
      completed: draftedAt != null,
      time: draftedAt,
    ),
  );

  items.add(
    TimelineItem(
      title: 'Submitted',
      subtitle: 'Launched to network',
      color: Colors.blue,
      completed: submittedAt != null,
      time: submittedAt,
    ),
  );


  //Show this section for skrambled pods only
  if (pod.mode != 5) {

    


  }

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
