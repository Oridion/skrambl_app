import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skrambl_app/services/price_service.dart';
import 'package:skrambl_app/services/wallet_balance_stream.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class WalletBalanceTile extends StatefulWidget {
  final AuthToken authToken;
  final String pubkey;

  const WalletBalanceTile({super.key, required this.authToken, required this.pubkey});

  @override
  State<WalletBalanceTile> createState() => _WalletBalanceTileState();
}

class _WalletBalanceTileState extends State<WalletBalanceTile> {
  final WalletBalanceStream _balanceStream = WalletBalanceStream();
  StreamSubscription<int>? _subscription;
  int? _lamports;
  double _solUsdPrice = 0;

  @override
  void initState() {
    super.initState();

    _subscription = _balanceStream.start(widget.pubkey).listen((lamports) async {
      final price = await fetchSolPriceUsd();

      if (mounted) {
        setState(() {
          _lamports = lamports;
          _solUsdPrice = price;

          //This is where I need to activate the button
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant WalletBalanceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pubkey != widget.pubkey) {
      _subscription?.cancel();
      _balanceStream.stop();
      _subscription = _balanceStream.start(widget.pubkey).listen((lamports) async {
        final price = await fetchSolPriceUsd();

        if (mounted) {
          setState(() {
            _lamports = lamports;
            _solUsdPrice = price;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _balanceStream.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sol = _lamports != null ? (_lamports! / 1e9).toStringAsFixed(2) : '0';
    final usd = (_lamports != null && _solUsdPrice > 0)
        ? (_lamports! / 1e9 * _solUsdPrice).toStringAsFixed(2)
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 82,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, -5), // x, y — move up 2px
                child: SolanaLogo(useDark: true, size: 24),
              ),
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
