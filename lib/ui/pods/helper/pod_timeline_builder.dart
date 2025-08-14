import 'package:flutter/material.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/pods/widgets/vertical_timeline.dart';

List<TimelineItem> buildTimeline({
  required DateTime? draftedAt,
  required DateTime? submittedAt,
  required DateTime? finalizedAt,
  required PodStatus status,
}) {
  final items = <TimelineItem>[];

  items.add(
    TimelineItem(
      title: 'Drafted',
      subtitle: 'Delivery created',
      color: Colors.grey,
      completed: draftedAt != null,
      time: draftedAt,
    ),
  );

  items.add(
    TimelineItem(
      title: 'Submitted',
      subtitle: 'Pod launched to network',
      color: Colors.blue,
      completed: submittedAt != null,
      time: submittedAt,
    ),
  );
  // Terminal state – finalized or failed
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
  } else {
    items.add(
      TimelineItem(
        title: 'Finalized',
        subtitle: 'Landing confirmed',
        color: Colors.green,
        completed: finalizedAt != null || status == PodStatus.finalized,
        time: finalizedAt,
      ),
    );
  }

  return items;
}
