import 'package:flutter/material.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class BurnerTile extends StatelessWidget {
  final BurnerWallet burner;
  final bool selected;
  final VoidCallback onTap;

  const BurnerTile({super.key, required this.burner, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final note = burner.note ?? '';
    final isUsed = burner.used;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.black : Colors.black12, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    shortenPubkey(burner.publicKey),
                    style: TextStyle(color: Colors.black.withOpacityCompat(0.65)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUsed ? Colors.red[100] : const Color.fromARGB(255, 231, 231, 231),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isUsed ? "Used" : "Unused",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUsed ? Colors.red[700] : const Color.fromARGB(255, 72, 72, 72),
                ),
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: Colors.black, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
