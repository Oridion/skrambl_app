// ===============================
// lib/ui/pods/widgets/pod_details_table.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PodDetailsTable extends StatelessWidget {
  final List<PodDetailRow> rows;
  const PodDetailsTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(0, 16, 0, 0),
      child: Column(children: [for (final r in rows) r]),
    );
  }
}

class PodDetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool copyable;
  final bool monospace;

  const PodDetailRow(this.title, this.value, {super.key, this.copyable = false, this.monospace = false});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(title, style: t.labelSmall?.copyWith(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: t.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
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
        ],
      ),
    );
  }
}
