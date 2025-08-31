import 'package:intl/intl.dart';

int estimateHops(int delaySeconds, {int waitPerHopSec = 180, int processingPerHopSec = 60}) {
  if (delaySeconds <= 0) return 2;
  final perHop = waitPerHopSec + processingPerHopSec; // default 240s
  final extraHops = delaySeconds ~/ perHop;
  return 2 + extraHops; // baseline 2 hops
}

class HopRange {
  final int min; // conservative: includes processing time
  final int max; // optimistic: assumes processing is negligible
  const HopRange(this.min, this.max);
}

HopRange estimateHopRange(int delaySeconds, {int waitPerHopSec = 180, int processingPerHopSec = 60}) {
  if (delaySeconds <= 0) return const HopRange(2, 2);
  final minHops = delaySeconds ~/ (waitPerHopSec + processingPerHopSec); // 240s
  final maxHops = delaySeconds ~/ waitPerHopSec; // 180s
  return HopRange(2 + minHops, 2 + maxHops); // baseline 2 hops
}

String getDelayText(int delaySeconds) {
  if (delaySeconds == 0) return 'Immediate';

  final minutesTotal = delaySeconds ~/ 60;
  final hours = minutesTotal ~/ 60;
  final minutes = minutesTotal % 60;

  if (hours > 0 && minutes > 0) {
    return '${hours}h ${minutes}m';
  } else if (hours > 0) {
    return '${hours}h';
  } else {
    return '${minutes}m';
  }
}

String getETAText(int delaySeconds) {
  if (delaySeconds == 0) return 'Now';

  final now = DateTime.now();
  final eta = now.add(Duration(seconds: delaySeconds));

  // Compare days (ignore time) to say Today/Tomorrow/Weekday/etc.
  DateTime dOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  final today = dOnly(now);
  final etaDay = dOnly(eta);
  final dayDiff = etaDay.difference(today).inDays;

  final time = DateFormat.jm().format(eta); // e.g., 2:37 PM

  if (dayDiff == 0) return 'Today $time';
  if (dayDiff == 1) return 'Tomorrow $time';
  if (dayDiff > 1 && dayDiff < 7) {
    return '${DateFormat.E().format(eta)} $time'; // Mon 2:37 PM
  }
  return '${DateFormat.MMMd().format(eta)} $time'; // Sep 3 2:37 PM
}
