// lib/ui/shared/solana_logo.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skrambl_app/constants/app.dart';

/// A drop-in Solana logo widget
class SolanaLogo extends StatelessWidget {
  final double? size;
  final bool useDark;
  final Color? color; // only used for white logo (or if you want to force a color)
  final BoxFit fit;
  final String? semanticsLabel;

  const SolanaLogo({
    super.key,
    this.size,
    this.useDark = false,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticsLabel = 'Solana',
  });

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? IconTheme.of(context).size ?? 24;
    final effectiveColor = color ?? IconTheme.of(context).color;

    final asset = useDark ? AppAssets.solanaLogoBlack : AppAssets.solanaLogoWhite;

    // For the full-color logo we typically avoid a ColorFilter (so colors stay true).
    final ColorFilter? filter = !useDark && effectiveColor != null
        ? ColorFilter.mode(effectiveColor, BlendMode.srcIn)
        : null;

    return SvgPicture.asset(
      asset,
      width: resolvedSize,
      height: resolvedSize,
      fit: fit,
      colorFilter: filter,
      semanticsLabel: semanticsLabel,
    );
  }
}
