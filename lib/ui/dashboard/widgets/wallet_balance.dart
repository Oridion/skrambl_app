import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/formatters.dart';

class WalletBalanceTile extends StatelessWidget {
  final String pubkey;
  const WalletBalanceTile({super.key, required this.pubkey});

  @override
  Widget build(BuildContext context) {
    // Ensure provider is started for this pubkey (no-op if already same key)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final w = context.read<WalletBalanceProvider>();
      if (w.pubkey != pubkey) w.start(pubkey);
    });

    final w = context.watch<WalletBalanceProvider>();
    final lamports = w.lamports ?? 0;
    final sol = formatSol(lamports / 1e9);
    final usd = w.usdBalance.toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 58,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.translate(
                offset: Offset(0, -2), // x, y — move up 2px
                child: SolanaLogo(size: 18, useDark: true),
              ),
              const SizedBox(width: 6),
              Text(
                sol,
                style: GoogleFonts.archivoBlack(fontSize: 54, color: Colors.black, letterSpacing: -2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(' ~\$$usd USD', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
      ],
    );
  }
}
