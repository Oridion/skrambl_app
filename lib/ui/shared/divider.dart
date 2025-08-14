import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double thickness;

  const AppDivider({super.key, required this.color, this.height = 1.0, this.thickness = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(height: height, width: double.infinity, color: color);
  }
}
