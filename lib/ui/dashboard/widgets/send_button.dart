import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';
import 'package:skrambl_app/ui/send/send_controller.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class SendButtonSliver extends StatelessWidget {
  const SendButtonSliver({super.key});

  @override
  Widget build(BuildContext context) {
    // Minimal state selection
    final sol = context.select<WalletProvider, double>((w) => w.solBalance);
    final isLoading = context.select<WalletProvider, bool>((w) => w.isLoading);
    final canSend = !isLoading && sol > 0;

    // Select auth token separately so button doesn’t rebuild on unrelated wallet changes
    final authToken = context.select<SeedVaultSessionManager, AuthToken?>((s) => s.authToken);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSend && authToken != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SendController(authToken: authToken)),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
            ),
            child: const Text('SEND SOL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
