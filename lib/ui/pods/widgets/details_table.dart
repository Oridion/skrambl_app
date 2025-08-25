// ===============================
// lib/ui/pods/widgets/pod_details_table.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/utils/solana.dart';

class PodDetailsTable extends StatelessWidget {
  final List<PodDetailRow> rows;
  const PodDetailsTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(0, 3, 0, 0),
      child: Column(children: [for (final r in rows) r]),
    );
  }
}

class PodDetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool copyable;
  final bool linkable;
  final bool monospace;

  const PodDetailRow(
    this.title,
    this.value, {
    super.key,
    this.copyable = false,
    this.linkable = false,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      height: 26,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(title, style: t.labelMedium?.copyWith(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: t.bodyMedium?.copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              tooltip: 'Copy $title',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title copied')));
                }
              },
            ),
          if (linkable)
            IconButton(
              tooltip: 'View on explorer',
              icon: const Icon(Icons.open_in_new, size: 14),
              onPressed: () => openAccountOnSolanaFM(context, title),
            ),
        ],
      ),
    );
  }
}
