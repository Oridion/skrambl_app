// lib/ui/burners/widgets/burner_balance_pill.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:skrambl_app/providers/minute_ticker.dart';
import 'package:skrambl_app/utils/colors.dart'; // optional

class BurnerBalancePill extends StatefulWidget {
  final String pubkey;
  final EdgeInsets padding;
  const BurnerBalancePill({
    super.key,
    required this.pubkey,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  State<BurnerBalancePill> createState() => _BurnerBalancePillState();
}

class _BurnerBalancePillState extends State<BurnerBalancePill> {
  int? _lamports;
  //double? _usdPrice;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-run on every minute tick
    context.watch<MinuteTicker>();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = _lamports == null); // spinner only on first run
    try {
      final lamports = await _fetchLamports(widget.pubkey);
      //final usd = await fetchSolPriceUsd();
      if (!mounted) return;
      setState(() {
        _lamports = lamports;
        //_usdPrice = usd;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget inner;
    if (_loading) {
      inner = const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2));
    } else if (_lamports == null) {
      inner = const Text('—', style: TextStyle(fontWeight: FontWeight.w700));
    } else {
      final sol = _lamports! / 1e9;
      //final usd = _usdPrice != null ? sol * _usdPrice! : null;
      inner = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${sol.toStringAsFixed(3)} SOL',
            style: t.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: t.colorScheme.onSurface,
            ),
          ),
          // if (usd != null)
          //   Text(
          //     '\$${usd.toStringAsFixed(2)}',
          //     style: t.textTheme.labelSmall?.copyWith(
          //       color: t.colorScheme.onSurface.withOpacityCompat(0.7),
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
        ],
      );
    }

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest.withOpacityCompat(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: inner,
    );
  }
}

/// Simple HTTP getBalance (you can swap to your SolanaClientService if you prefer)
Future<int> _fetchLamports(String pubkey) async {
  final resp = await http.post(
    Uri.parse("https://api.mainnet-beta.solana.com"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "jsonrpc": "2.0",
      "id": 1,
      "method": "getBalance",
      "params": [pubkey],
    }),
  );
  if (resp.statusCode != 200 || resp.body.isEmpty) return 0;
  final json = jsonDecode(resp.body) as Map<String, dynamic>;
  return (json['result']?['value'] as int?) ?? 0;
}
