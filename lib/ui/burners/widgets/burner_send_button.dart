// lib/ui/burners/widgets/burner_send_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/burner_balances_provider.dart';
import 'package:skrambl_app/providers/network_fee_provider.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/ui/send/send_controller.dart';

class BurnerSendButton extends StatelessWidget {
  final String burnerPubkey;
  final int burnerIndex;
  final int minLamports; // >= 1 to avoid zero-sends
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final String label;

  const BurnerSendButton({
    super.key,
    required this.burnerPubkey,
    required this.burnerIndex,
    this.minLamports = 1,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    this.borderRadius = 8,
    this.label = 'Send',
  });

  @override
  Widget build(BuildContext context) {
    final lamports = context.select<BurnerBalancesProvider, int>((b) => b.lamportsFor(burnerPubkey));
    final networkFee = context.select<NetworkFeeProvider, int>((f) => f.fee);
    final hasFunds = lamports >= (minLamports + networkFee);

    final session = context.watch<SeedVaultSessionManager>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: hasFunds
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SendController(
                        authToken: session.authToken!,
                        fromWalletOverride: burnerPubkey,
                        fromBurnerIndexOverride: burnerIndex,
                      ),
                    ),
                  );
                }
              : null,
          style: FilledButton.styleFrom(
            padding: padding,
            backgroundColor: hasFunds ? Colors.black : Colors.grey.shade500,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
          icon: const Icon(Icons.send, size: 18, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
