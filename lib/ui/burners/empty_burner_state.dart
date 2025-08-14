// lib/widgets/destination/empty_burner_state.dart
import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

class EmptyBurnerState extends StatelessWidget {
  final VoidCallback onCreate;
  const EmptyBurnerState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, size: 120, color: Colors.black54),
          const SizedBox(height: 12),
          const Text('No burner wallets yet', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Create a burner to use as a destination.',
            style: TextStyle(color: Colors.black.withOpacityCompat(0.7)),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create burner'),
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
