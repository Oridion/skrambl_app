import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/providers/burner_balances_provider.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/ui/burners/widgets/status_chip.dart';
import 'package:skrambl_app/utils/colors.dart';
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
    final t = Theme.of(context);
    // Narrow watches: only this pubkey’s lamports + a single SOL price
    final lamports = context.select<BurnerBalancesProvider, int>((p) => p.lamportsFor(burner.pubkey));
    final solUsd = context.select<PriceProvider, double>((p) => p.solUsd);

    final sol = lamports / 1e9;
    final usd = lamports == 0 ? 0.0 : sol * solUsd;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              // Left: text block (pubkey + title/note)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pubkey + USED chip inline
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            shortenPubkey(burner.pubkey),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 14),
                        StatusChip(used: burner.used),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Secondary line: note + small meta
                    Text(
                      _subtitle(burner),
                      style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right: balances (align to end)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${formatSol(sol)} SOL', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 1),
                  Text(
                    '\$${usd.toStringAsFixed(2)}',
                    style: TextStyle(color: t.colorScheme.onSurface.withOpacityCompat(0.6), fontSize: 12),
                  ),
                ],
              ),

              // Menu
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

  static String _subtitle(Burner b) {
    final parts = <String>[];
    if ((b.note ?? '').isNotEmpty) parts.add(b.note!);
    //parts.add('Txs ${b.txCount}');
    //if (b.lastUsedAt != null) parts.add('Used ${_relative(b.lastUsedAt!)}');
    return parts.join(' · ');
  }

  // static String _relative(int unix) {
  //   final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(unix * 1000));
  //   if (d.inMinutes < 1) return 'just now';
  //   if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  //   if (d.inHours < 24) return '${d.inHours}h ago';
  //   return '${d.inDays}d ago';
  // }
}
