import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/utils/formatters.dart'; // for shortenPubkey

class PodIdentityGrid extends StatelessWidget {
  final String localId;
  final int? podId; // u16
  final String pda;
  final String creator;

  const PodIdentityGrid({
    super.key,
    required this.localId,
    required this.podId,
    required this.pda,
    required this.creator,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <Widget>[
      _MonoCopyRow(label: 'Pod ID', value: podId?.toString() ?? '—'),
      _MonoCopyRow(label: 'PDA', value: pda),
      _MonoCopyRow(label: 'Creator', value: creator),
    ];

    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(12, 12, 12, 4),
      child: Column(children: [for (final e in entries) e]),
    );
  }
}

class _MonoCopyRow extends StatelessWidget {
  final String label;
  final String value;
  const _MonoCopyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: t.labelSmall?.copyWith(color: Colors.black54)),
        ),
        Expanded(child: SelectableText(value == '—' ? value : shortenPubkey(value), style: t.bodyMedium)),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copy',
          onPressed: value == '—'
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied')));
                  }
                },
        ),
      ],
    );
  }
}
