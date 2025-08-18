import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/utils/logger.dart'; // Pod type

int? deriveDeliveryDurationSec(Pod p) {
  final s = p.submittedAt; // seconds epoch
  final f = p.finalizedAt; // seconds epoch
  if (s == null || f == null) return null;
  final d = f - s;
  return d >= 0 ? d : 0;
}

String formatDurationHMS(int seconds) {
  skrLogger.i(seconds);

  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
