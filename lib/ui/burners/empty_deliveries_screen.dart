import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

class EmptyDeliveries extends StatelessWidget {
  const EmptyDeliveries({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department, size: 48, color: Color.fromARGB(136, 141, 141, 141)),
            const SizedBox(height: 10),
            const Text('No deliveries yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              'Transactions sent from or to this burner will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withOpacityCompat(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
