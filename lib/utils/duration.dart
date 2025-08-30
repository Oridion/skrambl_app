import 'package:skrambl_app/data/local_database.dart';

int? deriveDeliveryDurationSec(Pod p) {
  final s = p.submittedAt; // seconds epoch
  final f = p.finalizedAt; // seconds epoch
  if (s == null || f == null) return null;
  final d = f - s;
  return d >= 0 ? d : 0;
}

String formatDurationReadable(int seconds) {
  if (seconds < 60) {
    return "$seconds sec";
  } else if (seconds % 60 == 0) {
    final minutes = seconds ~/ 60;
    return "$minutes min";
  } else {
    final minutes = seconds ~/ 60;
    final remainingSec = seconds % 60;
    return "$minutes min $remainingSec sec";
  }
}
