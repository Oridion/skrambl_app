import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  Color? backgroundColor,
  Color? textColor,
  SnackBarBehavior behavior = SnackBarBehavior.floating,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor ?? Colors.white)),
        duration: duration,
        backgroundColor: backgroundColor ?? Colors.black87,
        behavior: behavior,
      ),
    );
}
