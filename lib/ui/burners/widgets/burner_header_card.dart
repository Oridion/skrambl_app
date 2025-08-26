import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/local_database.dart' show Burner;
import 'package:skrambl_app/providers/burner_balances_provider.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart'; // formatSol()

class HeaderCard extends StatelessWidget {
  final String pubkey;
  final Burner? burner;

  const HeaderCard({super.key, required this.pubkey, this.burner});

  @override
  Widget build(BuildContext context) {
    final balances = context.watch<BurnerBalancesProvider>();
    final price = context.select<PriceProvider, double?>((p) => p.solUsd);

    final lamports = balances.lamportsFor(pubkey);
    final sol = lamports / 1e9;
    final usd = price != null ? sol * price : 0;

    final note = burner?.note;
    final used = burner?.used == true;
    final idx = burner?.derivationIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              // Left side: address + note + tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Text(
                      shortenPubkey(pubkey, length: 8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 3),

                    // Optional note
                    if ((note ?? '').isNotEmpty)
                      Text(
                        note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black.withOpacityCompat(0.7)),
                      ),

                    const SizedBox(height: 10),

                    // Chips (USED / UNUSED, IDX)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(
                          used ? 'USED' : 'UNUSED',
                          used ? const Color.fromARGB(255, 253, 236, 238) : const Color(0xFFF2F2F2),
                          used ? const Color.fromARGB(255, 168, 32, 32) : Colors.black87,
                        ),
                        if (idx != null) _chip('IDX: $idx', const Color(0xFFF2F2F2), Colors.black87),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right side: balances
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatSol(sol)} SOL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  if (price != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      usd <= 0 ? '\$0 USD' : '\$${usd.toStringAsFixed(2)} USD',
                      style: TextStyle(color: Colors.black.withOpacityCompat(0.65), fontSize: 13),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
