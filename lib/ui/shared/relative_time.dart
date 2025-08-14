import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/minute_ticker.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class RelativeTimeListen extends StatelessWidget {
  final DateTime time;
  final TextStyle? style;
  final String? locale;

  const RelativeTimeListen({super.key, required this.time, this.style, this.locale});

  @override
  Widget build(BuildContext context) {
    context.watch<MinuteTicker>();

    final now = DateTime.now();
    final diff = now.difference(time);

    final String displayText;
    if (diff.inMinutes < 60) {
      displayText = timeago.format(time, locale: locale);
    } else {
      final formatter = DateFormat('MMM d, yyyy • h:mm a');
      displayText = formatter.format(time);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 11, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 4),
        Text(displayText.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
