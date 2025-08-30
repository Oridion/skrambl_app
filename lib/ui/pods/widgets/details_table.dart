// ===============================
// lib/ui/pods/widgets/pod_details_table.dart
// ===============================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/utils/logger.dart';
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
  final String copyText;
  final bool copyable;
  final bool linkable;
  final bool monospace;

  const PodDetailRow(
    this.title,
    this.value, {
    super.key,
    this.copyText = '',
    this.copyable = false,
    this.linkable = false,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    skrLogger.i(value);
    return Container(
      height: 26,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(title, style: t.labelMedium?.copyWith(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: t.bodyMedium?.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          if (copyable)
            SizedBox(
              width: 25,
              child: IconButton(
                icon: const Icon(Icons.copy, size: 13),
                tooltip: 'Copy $title',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: copyText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title copied')));
                  }
                },
              ),
            ),

          if (linkable)
            SizedBox(
              width: 25,
              child: IconButton(
                tooltip: 'View on explorer',
                icon: const Icon(Icons.open_in_new, size: 13),
                onPressed: () => openAccountOnSolanaFM(context, title),
              ),
            ),
        ],
      ),
    );
  }
}
