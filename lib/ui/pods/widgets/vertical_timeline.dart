import 'package:flutter/material.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/ui/pods/widgets/dot.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

// Timeline item model
class TimelineItem {
  final String title;
  final String? subtitle;
  final String? badge; // e.g., tx status or network
  final DateTime? time;
  final Color color;
  final bool completed;
  final Widget? trailing; // e.g., copy buttons for IDs

  const TimelineItem({
    required this.title,
    this.subtitle,
    this.badge,
    required this.color,
    required this.completed,
    this.time,
    this.trailing,
  });
}

// Timeline container
class VerticalTimeline extends StatelessWidget {
  final List<TimelineItem> items;
  final Pod? pod;

  const VerticalTimeline({super.key, required this.items, this.pod});

  @override
  Widget build(BuildContext context) {
    if (pod == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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

// Timeline tile
class TimelineTile extends StatelessWidget {
  final TimelineItem item;
  final bool isFirst;
  final bool isLast;
  const TimelineTile({super.key, required this.item, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column - timeline dots and lines
          Column(
            children: [
              SizedBox(height: isFirst ? 0 : 0),
              Dot(color: item.color, filled: false),
              Expanded(
                child: Container(
                  width: 3,
                  margin: EdgeInsets.only(top: isFirst ? 0 : 0, bottom: isLast ? 6 : 0),
                  decoration: BoxDecoration(color: isLast ? Colors.transparent : Colors.black12),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Content - (2nd column row)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacityCompat(0.5), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.time != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(
                        formatTime(item.time!.millisecondsSinceEpoch),
                        style: t.bodyMedium?.copyWith(fontSize: 14),
                      ),
                    ),

                  Row(
                    children: [
                      Text(item.title, style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      if (item.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacityCompat(.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(item.badge!, style: t.labelSmall?.copyWith(letterSpacing: .3)),
                        ),
                    ],
                  ),

                  if (item.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.subtitle!,
                        style: t.bodyMedium?.copyWith(color: Colors.black54, fontSize: 14),
                      ),
                    ),

                  if (item.trailing != null)
                    Padding(padding: const EdgeInsets.only(top: 8), child: item.trailing!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
