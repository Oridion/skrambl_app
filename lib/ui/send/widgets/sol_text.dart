import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/formatters.dart';

class SolText extends StatelessWidget {
  final double amount;
  final String suffix;
  final TextStyle? style;
  final bool bold;
  final Color? color;
  final double? fontSize;

  const SolText({
    super.key,
    required this.amount,
    this.suffix = ' SOL',
    this.style,
    this.bold = false,
    this.color,
    this.fontSize,
  });

  factory SolText.fromLamports({
    required BigInt lamports,
    String suffix = ' SOL',
    TextStyle? style,
    bool bold = false,
    Color? color,
    double? fontSize,
  }) {
    return SolText(
      amount: lamports.toDouble() / 1e9,
      suffix: suffix,
      style: style,
      bold: bold,
      color: color,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${formatSol(amount)}${suffix.isEmpty || suffix.startsWith(' ') ? '' : ' '}$suffix',
      style:
          style ??
          TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
            fontSize: fontSize ?? 16,
          ),
    );
  }
}
