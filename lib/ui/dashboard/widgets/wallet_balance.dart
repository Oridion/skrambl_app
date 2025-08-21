import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/formatters.dart';

class WalletBalanceTile extends StatelessWidget {
  final String pubkey;
  const WalletBalanceTile({super.key, required this.pubkey});

  @override
  Widget build(BuildContext context) {
    // Ensure provider is started for this pubkey (no-op if already same key)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final w = context.read<WalletProvider>();
      if (w.pubkey != pubkey) w.setAccount(pubkey);
    });

    final w = context.watch<WalletProvider>();
    final lamports = w.lamports ?? 0;
    final sol = formatSol(lamports / 1e9);
    //final sol = "891.2658";
    final usd = w.usdBalance.toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 77,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Baseline(
                baseline: 55, // tune this until it feels right
                baselineType: TextBaseline.alphabetic,
                child: SolanaLogo(size: 18, useDark: true),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: AutoSizeText(
                  sol,
                  maxLines: 1,
                  minFontSize: 20,
                  maxFontSize: 64,
                  style: GoogleFonts.archivoBlack(fontSize: 64, color: Colors.black, letterSpacing: -1.0),
                ),
              ),
            ],
          ),
        ),
        Text(' ~\$$usd USD', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
      ],
    );
  }
}
