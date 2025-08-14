import 'package:flutter/material.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';
import 'package:skrambl_app/utils/colors.dart';

class BurnerTile extends StatelessWidget {
  final BurnerWallet burner;
  final bool selected;
  final VoidCallback onTap;

  const BurnerTile({super.key, required this.burner, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final note = burner.note ?? 'Burner #${burner.index}';
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
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    _shorten(burner.publicKey),
                    style: TextStyle(color: Colors.black.withOpacityCompat(0.65)),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  String _shorten(String pk) => pk.length <= 10 ? pk : '${pk.substring(0, 4)}…${pk.substring(pk.length - 4)}';
}
