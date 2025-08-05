import 'package:flutter/material.dart';
import '../send_form_model.dart';

class SendTypeSelectionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final SendFormModel formModel;

  const SendTypeSelectionScreen({
    super.key,
    required this.onNext,
    required this.formModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectionBox(
            context,
            title: 'Send SKRAMBLED',
            description:
                'Route your SOL through Oridion for a privacy-preserving transaction path.',
            eta: 'Estimated delivery: minimum ~45 seconds',
            onTap: () {
              formModel.isSkrambled = true;
              onNext();
            },
          ),
          const SizedBox(height: 20),
          _buildSelectionBox(
            context,
            title: 'Send Standard',
            description:
                'Send SOL directly to the destination without routing through Oridion.',
            eta: 'Estimated delivery: Near instant',
            onTap: () {
              formModel.isSkrambled = false;
              onNext();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBox(
    BuildContext context, {
    required String title,
    required String description,
    required String eta, // ⬅️ new
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              eta,
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 225, 213, 166),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
