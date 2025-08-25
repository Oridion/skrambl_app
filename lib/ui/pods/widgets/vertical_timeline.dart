import 'package:flutter/material.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/ui/pods/helper/pod_timeline_builder.dart';
import 'package:skrambl_app/ui/pods/widgets/timeline_tile.dart';

// Timeline container
class VerticalTimeline extends StatelessWidget {
  final Pod pod;

  const VerticalTimeline({super.key, required this.pod});

  @override
  Widget build(BuildContext context) {
    final items = buildTimeline(pod: pod);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++)
            TimelineTile(item: items[i], isFirst: i == 0, isLast: i == items.length - 1),
        ],
      ),
    );
  }
}
