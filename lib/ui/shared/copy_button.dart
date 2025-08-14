import 'package:flutter/material.dart';

class CopyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  final bool darkBg;

  const CopyButton({super.key, required this.onTap, required this.enabled, required this.darkBg});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: enabled ? 'Copy address' : 'No address',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? (darkBg ? Colors.white12 : Colors.black12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.copy_rounded,
            size: 16,
            color: enabled ? (darkBg ? Colors.white : Colors.black87) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
