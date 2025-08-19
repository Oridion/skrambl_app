import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/utils/formatters.dart';

class DestinationRow extends StatelessWidget {
  final String address;
  final bool isBurner;
  final bool copyable;

  const DestinationRow({super.key, required this.address, required this.isBurner, this.copyable = false});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final short = shortenPubkey(address);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          const Text(
            'DESTINATION',
            style: TextStyle(fontSize: 12, color: Colors.black54, letterSpacing: 0.4),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(short, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                if (isBurner) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 18),
                ],
              ],
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: address));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(address)));
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
