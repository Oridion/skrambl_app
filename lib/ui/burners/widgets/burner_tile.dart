import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/burner_balances_provider.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';
import 'package:skrambl_app/ui/burners/widgets/status_chip.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:flutter/services.dart';

class BurnerTile extends StatelessWidget {
  final BurnerWallet burner;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BurnerTile({
    super.key,
    required this.burner,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final note = (burner.note ?? '').trim();
    final title = note.isEmpty ? 'Burner #${burner.index}' : note;
    final baseBg = t.colorScheme.surfaceContainerHighest.withOpacityCompat(0.35);
    final borderColor = selected ? t.colorScheme.onSurface : Colors.black12;

    // Narrow watch: only the lamports for this pubkey + the single SOL price value
    final lamports = context.select<BurnerBalancesProvider, int>((p) => p.lamportsFor(burner.publicKey));
    final solUsd = context.select<PriceProvider, double>((p) => p.solUsd);

    final sol = lamports / 1e9;
    final usd = lamports == 0 ? 0.0 : sol * solUsd;

    return Semantics(
      button: true,
      label: 'Burner ${burner.index}, ${burner.used ? "used" : "unused"}',
      // announce balances too
      value: '${sol.toStringAsFixed(3)} SOL, \$${usd.toStringAsFixed(2)}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress:
            onLongPress ??
            () async {
              await Clipboard.setData(ClipboardData(text: burner.publicKey));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address copied')));
              }
            },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: baseBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              // left: texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortenPubkey(burner.publicKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: t.colorScheme.onSurface.withOpacityCompat(0.65),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // center: balances
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
                    child: Text(
                      '${formatSol(sol)} SOL',
                      key: ValueKey(lamports), // switch when lamports change
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),

                  Text(
                    '\$${usd.toStringAsFixed(2)}',
                    style: TextStyle(color: t.colorScheme.onSurface.withOpacityCompat(0.6), fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(width: 30),
              StatusChip(used: burner.used),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: t.colorScheme.onSurface, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
