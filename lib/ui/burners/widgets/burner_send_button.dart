// lib/ui/burner/burner_send_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/ui/send/send_controller.dart';

class BurnerSendButton extends StatefulWidget {
  final String burnerPubkey;
  final int minLamports; // disable if below this (default: > 0)
  final int? burnerIndex; // optional: pass if you want SendController to know the index
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final String label;

  const BurnerSendButton({
    super.key,
    required this.burnerPubkey,
    this.burnerIndex,
    this.minLamports = 1,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    this.borderRadius = 8,
    this.label = "Send",
  });

  @override
  State<BurnerSendButton> createState() => _BurnerSendButtonState();
}

class _BurnerSendButtonState extends State<BurnerSendButton> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    // Ensure the balance watcher is started for this pubkey
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final w = context.read<WalletBalanceProvider>();
      if (w.pubkey != widget.burnerPubkey) {
        w.start(widget.burnerPubkey);
      }
    });
    _started = true;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SeedVaultSessionManager>();
    final w = context.watch<WalletBalanceProvider>();
    final lamports = (w.pubkey == widget.burnerPubkey) ? (w.lamports ?? 0) : 0;
    final hasFunds = lamports >= widget.minLamports;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16), // keep your page rhythm
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
                        fromWalletOverride: widget.burnerPubkey,
                        fromBurnerIndexOverride: widget.burnerIndex,
                      ),
                    ),
                  );
                }
              : null, // disabled when not enough funds
          style: FilledButton.styleFrom(
            padding: widget.padding,
            backgroundColor: hasFunds ? Colors.black : Colors.grey.shade500,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius)),
          ),
          icon: const Icon(Icons.send, size: 18, color: Colors.white),
          label: Text(
            widget.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
