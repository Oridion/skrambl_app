import 'package:flutter/material.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:solana/solana.dart';
import 'package:url_launcher/url_launcher.dart';

/// Converts a base58 string address into an Ed25519HDPublicKey.
/// Throws [FormatException] if the address is invalid.
Ed25519HDPublicKey toPublicKey(String address) {
  return Ed25519HDPublicKey.fromBase58(address);
}

// Open signature in solana fm
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

//Check if pubkey has history. (For creating burner wallets)
Future<bool> hasOnChainHistory(String pubkey) async {
  final rpc = SolanaClientService().rpcClient;
  try {
    // Any signature means it was used before
    final sigs = await rpc.getSignaturesForAddress(pubkey, limit: 1);
    if (sigs.isNotEmpty) return true;

    // Optional: also treat a live account as "used"
    final info = await rpc.getAccountInfo(pubkey);
    return info.value != null; // account exists (data or lamports)
  } catch (_) {
    // On transient RPC errors, be conservative and retry upstream or treat as used
    return true;
  }
}
