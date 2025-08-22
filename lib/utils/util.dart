import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyToClipboardWithToast(BuildContext context, String text, {String label = 'Address'}) async {
  await Clipboard.setData(ClipboardData(text: text));

  if (!context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 1)));
}
