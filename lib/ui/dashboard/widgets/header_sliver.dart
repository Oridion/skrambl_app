import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart' show Selector2;
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/selected_wallet_provider.dart';
import 'package:skrambl_app/ui/dashboard/sections/dashboard_header.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class HeaderSliver extends StatelessWidget {
  const HeaderSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector2<SeedVaultSessionManager, SelectedWalletProvider, (AuthToken?, String?)>(
      selector: (_, a, b) => (a.authToken, b.pubkey), // Dart 3 record
      builder: (context, creds, _) {
        final (authToken, pubkey) = creds;

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 8),
          sliver: SliverToBoxAdapter(
            child: (authToken != null && pubkey != null)
                ? DashboardHeader(authToken: authToken, pubkey: pubkey)
                : const _HeaderSkeleton(),
          ),
        );
      },
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
