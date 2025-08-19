// lib/widgets/destination/empty_burner_state.dart
import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

class EmptyBurnerState extends StatelessWidget {
  final VoidCallback onCreate;
  const EmptyBurnerState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, size: 120, color: Colors.black54),
          const SizedBox(height: 12),
          const Text('No burner wallets yet', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
            'Set up burner addresses ready with funds passed through Oridion to have private funds ready for later use.',
            style: TextStyle(color: Colors.black.withOpacityCompat(0.7)),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create burner'),
          ),
        ],
      ),
    );
  }
}
