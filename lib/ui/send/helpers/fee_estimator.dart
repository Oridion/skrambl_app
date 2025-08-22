import 'package:skrambl_app/constants/app.dart';

double computeMaxSendableSol({
  required double walletBalanceSol,
  required double privacyFeeSol, // your delay-based fee
  required int networkFeeLamports, // from NetworkFeeProvider.fee
  int safetyLamports = 20000, // small buffer for rounding/drift
}) {
  final walletLamports = (walletBalanceSol * AppConstants.lamportsPerSol).floor();
  final privacyLamports = (privacyFeeSol * AppConstants.lamportsPerSol).ceil();

  final maxLamports = walletLamports - privacyLamports - networkFeeLamports - safetyLamports;
  if (maxLamports <= 0) return 0.0;
  return maxLamports / AppConstants.lamportsPerSol;
}
