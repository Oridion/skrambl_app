import 'package:skrambl_app/constants/app.dart';

double computeMaxSendableSol({
  required double walletBalanceSol,
  required double privacyFeeSol, // 0 for standard; your calc for skrambled
  required int networkFeeLamports,
  int cushionLamports = 2000, // tiny safety buffer
}) {
  const double lamportsPerSol = 1e9;
  final double networkFeeSol = (networkFeeLamports + cushionLamports) / lamportsPerSol;

  final double max = walletBalanceSol - privacyFeeSol - networkFeeSol;
  // Clamp to >= 0 and trim minor FP noise
  return max > 0 ? double.parse(max.toStringAsFixed(9)) : 0.0;
}

//Calculate fee based on delay seconds
double calculateDelayFee(int delaySeconds, BigInt? baseFee, BigInt? incrementFee) {
  if (baseFee == null || incrementFee == null) return 0;
  final int tiers = (delaySeconds / 180).floor();
  final feeLamports = baseFee + (incrementFee * BigInt.from(tiers));
  final feeSol = feeLamports / BigInt.from(AppConstants.lamportsPerSol);
  return feeSol.toDouble();
}

int calculateDelayFeeLamports(int delaySeconds, int? baseFeeLamports, int? incLamports) {
  if (baseFeeLamports == null || incLamports == null) return 0;
  final tiers = delaySeconds ~/ 180;
  return baseFeeLamports + (incLamports * tiers);
}
