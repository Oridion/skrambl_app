// timeline_item.dart
import 'package:flutter/material.dart';

class TimelineItem {
  final String title;
  final String? subtitle;
  final Widget? countdownWidget;
  final DateTime? at;
  final Color color;
  final bool isActive;

  const TimelineItem({
    required this.title,
    this.subtitle,
    this.countdownWidget,
    this.at,
    required this.color,
    required this.isActive,
  });
}
