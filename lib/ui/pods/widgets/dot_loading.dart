import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/pods/widgets/dot.dart';
import 'package:skrambl_app/utils/colors.dart';

class DotLoading extends StatelessWidget {
  final Color color;
  final bool filled;
  final bool loading;

  const DotLoading({super.key, required this.color, this.filled = false, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: loading
          ? DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacityCompat(0.4), width: 1),
              ),
              child: SizedBox(
                key: const ValueKey('loading'),
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            )
          : Dot(key: const ValueKey('dot'), color: color, filled: filled),
    );
  }
}
