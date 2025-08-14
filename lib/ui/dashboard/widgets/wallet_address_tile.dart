import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/utils/formatters.dart';

class WalletAddressTile extends StatelessWidget {
  final String pubkey;
  const WalletAddressTile({super.key, required this.pubkey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRIMARY WALLET', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 92),
              child: SelectableText(shortenPubkey(pubkey)),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: pubkey));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Address copied to clipboard')));
              },
            ),
          ],
        ),
      ],
    );
  }
}
