import 'package:flutter/material.dart';

/// A pulsing skeleton shimmer bar, useful for displaying
/// placeholder price values while loading.
///
/// Example:
/// ```dart
/// const PriceSkeleton(color: Colors.grey)
/// ```
class PriceSkeleton extends StatefulWidget {
  final Color color;
  const PriceSkeleton({super.key, required this.color});

  @override
  State<PriceSkeleton> createState() => _PriceSkeletonState();
}

class _PriceSkeletonState extends State<PriceSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _fade = Tween(
    begin: 0.35,
    end: 0.85,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: 10,
          width: 80,
          decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}
