import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/minute_ticker.dart';
import 'package:timeago/timeago.dart' as timeago;

class RelativeTimeListen extends StatelessWidget {
  final DateTime time;
  final TextStyle? style;
  final String? locale;

  const RelativeTimeListen({super.key, required this.time, this.style, this.locale});

  @override
  Widget build(BuildContext context) {
    // rebuild when the ticker notifies (once per minute)
    context.watch<MinuteTicker>();
    return Text(timeago.format(time, locale: locale), style: style);
  }
}
