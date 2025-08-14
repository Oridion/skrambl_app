import 'package:flutter/material.dart';

extension ColorAlpha on Color {
  /// Apply alpha using a 0.0–1.0 double, converts internally to 0–255
  Color withOpacityCompat(double opacity) {
    final alphaValue = (255 * opacity).clamp(0, 255).toInt();
    return withAlpha(alphaValue);
  }
}
