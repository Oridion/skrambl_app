import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  final double spacing; // vertical spacing between rows
  final double indent; // left gap before bullet
  final TextStyle? textStyle;
  final double bulletSize; // bullet dot size
  final Color? bulletColor;

  const BulletList({
    super.key,
    required this.items,
    this.spacing = 6,
    this.indent = 2,
    this.textStyle,
    this.bulletSize = 6,
    this.bulletColor,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        textStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.25,
          color: Colors.black.withOpacityCompat(0.65),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final text in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: indent),
              Container(
                margin: const EdgeInsets.only(top: 7), // aligns bullet with first text line
                height: bulletSize,
                width: bulletSize,
                decoration: BoxDecoration(
                  color: bulletColor ?? Colors.black.withOpacityCompat(0.75),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: style)),
            ],
          ),
          SizedBox(height: spacing),
        ],
      ],
    );
  }
}
