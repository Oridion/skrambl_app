import 'package:flutter/material.dart';
import 'package:solana/solana.dart';
import 'package:url_launcher/url_launcher.dart';

/// Converts a base58 string address into an Ed25519HDPublicKey.
/// Throws [FormatException] if the address is invalid.
Ed25519HDPublicKey toPublicKey(String address) {
  return Ed25519HDPublicKey.fromBase58(address);
}

Future<void> openOnSolanaFM(BuildContext context, String sigBase58) async {
  final url = Uri.parse('https://solana.fm/tx/$sigBase58'); // add ?cluster=devnet-solana if needed
  try {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      // Fallback to default mode
      final ok2 = await launchUrl(url);
      if (!ok2 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open SolanaFM')));
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open SolanaFM')));
    }
  }
}
