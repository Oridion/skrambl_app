import 'package:flutter/material.dart';

class SquareSliderThumbShape extends SliderComponentShape {
  final double size;

  const SquareSliderThumbShape({this.size = 20});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(size, size);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter? labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint()..color = sliderTheme.thumbColor ?? Colors.black;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size, height: size),
      const Radius.circular(4), // <--- boxy corners here
    );

    canvas.drawRRect(rect, paint);
  }
}
