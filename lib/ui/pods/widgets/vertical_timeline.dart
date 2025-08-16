import 'package:flutter/material.dart';
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
  const VerticalTimeline({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(12, 20, 12, 20),
      child: Column(
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
          // Left rail
          Column(
            children: [
              SizedBox(height: isFirst ? 6 : 0),
              Dot(color: item.color, filled: item.completed),
              Expanded(
                child: Container(
                  width: 2,
                  margin: EdgeInsets.only(top: isFirst ? 6 : 0, bottom: isLast ? 6 : 0),
                  decoration: BoxDecoration(color: isLast ? Colors.transparent : Colors.black12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      child: Text(item.subtitle!, style: t.bodySmall?.copyWith(color: Colors.black54)),
                    ),
                  if (item.time != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(formatFullDateTime(item.time!.millisecondsSinceEpoch), style: t.bodySmall),
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
