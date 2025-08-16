import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

class TransferDiagram extends StatelessWidget {
  final String fromLabel;
  final String fromAddress;
  final String toLabel;
  final String toAddress;
  final double amountSol;
  final String? amountUsd;
  final VoidCallback? onCopyFrom;
  final VoidCallback? onCopyTo;

  const TransferDiagram({
    super.key,
    required this.fromLabel,
    required this.fromAddress,
    required this.toLabel,
    required this.toAddress,
    required this.amountSol,
    this.amountUsd,
    this.onCopyFrom,
    this.onCopyTo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AddressCard(
          label: fromLabel,
          address: fromAddress,
          leading: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.black),
          onCopy: onCopyFrom,
        ),

        // Arrow + amount chip
        const SizedBox(height: 12),
        Column(
          children: [
            Icon(Icons.arrow_downward_rounded, color: Colors.black.withOpacityCompat(0.6)),
            //const SizedBox(height: 8),
            // _AmountChip(sol: amountSol, usd: amountUsd),
            // const SizedBox(height: 8),
            //Icon(Icons.arrow_downward_rounded, color: Colors.black.withOpacityCompat(0.6)),
          ],
        ),
        const SizedBox(height: 12),

        _AddressCard(
          label: toLabel,
          address: toAddress,
          leading: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.black),
          onCopy: onCopyTo,
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final String label;
  final String address;
  final Widget leading;
  final VoidCallback? onCopy;

  const _AddressCard({required this.label, required this.address, required this.leading, this.onCopy});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: t.labelLarge?.copyWith(color: Colors.black54)),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: t.titleSmall?.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(tooltip: 'Copy', icon: const Icon(Icons.copy, size: 18), onPressed: onCopy),
        ],
      ),
    );
  }
}
