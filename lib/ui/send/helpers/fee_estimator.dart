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
