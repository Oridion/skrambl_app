import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';

class WithWalletBalance extends StatelessWidget {
  final String pubkey;
  final Widget child;
  const WithWalletBalance({super.key, required this.pubkey, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // new, local instance so we don't fight the global one
      create: (ctx) {
        final p = WalletProvider(ctx.read<PriceProvider>());
        p.setAccount(pubkey);
        return p;
      },
      child: child,
    );
  }
}
