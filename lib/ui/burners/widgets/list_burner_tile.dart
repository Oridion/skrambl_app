import 'package:flutter/material.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/utils/formatters.dart';

class ListBurnerTile extends StatelessWidget {
  final Burner burner;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback onEditNote;
  final VoidCallback onArchive;

  const ListBurnerTile({
    super.key,
    required this.burner,
    required this.onTap,
    required this.onCopy,
    required this.onEditNote,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[];
    if ((burner.note ?? '').isNotEmpty) subtitle.add(burner.note!);
    //subtitle.add('Index ${burner.derivationIndex}');
    subtitle.add('Txs ${burner.txCount}');
    if (burner.lastUsedAt != null) subtitle.add('Used ${_relative(burner.lastUsedAt!)}');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            shortenPubkey(burner.pubkey),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (burner.used)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('USED', style: TextStyle(fontSize: 11, letterSpacing: 0.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.join(' • '),
                      style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'copy':
                      onCopy();
                      break;
                    case 'edit':
                      onEditNote();
                      break;
                    case 'archive':
                      onArchive();
                      break;
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'copy', child: Text('Copy address')),
                  PopupMenuItem(value: 'edit', child: Text('Edit note')),
                  PopupMenuItem(value: 'archive', child: Text('Archive')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _relative(int unix) {
    final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(unix * 1000));
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
