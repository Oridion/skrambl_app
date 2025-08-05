import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart'; // for AuthToken
import 'package:skrambl_app/services/seed_vault_service.dart';

class WalletAddressTile extends StatelessWidget {
  final AuthToken authToken;
  final String pubkey;

  const WalletAddressTile({
    super.key,
    required this.authToken,
    required this.pubkey,
  });

  @override
  Widget build(BuildContext context) {
    String shortenPubkey(String pubkey) {
      if (pubkey.length <= 10) return pubkey;
      return '${pubkey.substring(0, 4).toUpperCase()}..${pubkey.substring(pubkey.length - 4).toUpperCase()}';
    }

    return FutureBuilder<String?>(
      future: SeedVaultService.getPublicKeyString(authToken: authToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Text('Failed to load public key.');
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PRIMARY WALLET',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 92),
                  child: SelectableText(
                    shortenPubkey(snapshot.data!),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact, // 👈 tighter spacing
                  padding: EdgeInsets.zero, // 👈 no extra padding
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy full address',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: snapshot.data!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Address copied to clipboard'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
