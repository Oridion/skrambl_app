import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';

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
    final sol = (lamports / 1e9).toStringAsFixed(2);
    final usd = w.usdBalance.toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 82,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SolanaLogo(useDark: true, size: 24),
              const SizedBox(width: 8),
              Text(sol, style: GoogleFonts.archivoBlack(fontSize: 77, color: Colors.black)),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(' ~\$$usd USD', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
      ],
    );
  }
}
