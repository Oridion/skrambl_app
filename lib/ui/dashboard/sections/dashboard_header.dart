// lib/ui/dashboard/widgets/header_section.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skrambl_app/ui/dashboard/widgets/wallet_balance.dart';
import 'package:skrambl_app/ui/dashboard/widgets/wallet_address_tile.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class DashboardHeader extends StatefulWidget {
  final AuthToken authToken;
  final String? pubkey;

  const DashboardHeader({
    super.key,
    required this.authToken,
    required this.pubkey,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      // decoration: BoxDecoration(
      //   color: const Color.fromARGB(95, 239, 237, 228),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: widget.pubkey != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SKRAMBL.",
                  style: GoogleFonts.archivoBlack(
                    fontSize: 44,
                    color: const Color.fromARGB(255, 205, 205, 205),
                  ),
                ),
                const SizedBox(height: 32), // buffer space
                WalletAddressTile(
                  authToken: widget.authToken,
                  pubkey: widget.pubkey!,
                ),
                WalletBalanceTile(
                  authToken: widget.authToken,
                  pubkey: widget.pubkey!,
                ),
              ],
            )
          : const Center(
              child: Text(
                "Failed to load wallet.",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
    );
  }
}
