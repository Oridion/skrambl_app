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
