import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/formatters.dart';
import '../send_form_model.dart';

class SkrambledSummaryScreen extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onBack;
  final SendFormModel formModel;

  const SkrambledSummaryScreen({
    super.key,
    required this.onSend,
    required this.onBack,
    required this.formModel,
  });

  String get delayText {
    final delay = formModel.delaySeconds;
    if (delay == 0) return 'Immediate';
    if (delay < 60) return '$delay seconds';
    final min = (delay / 60).round();
    return '$min minute${min == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final destination = formModel.destinationWallet ?? '—';
    final amount = formatSol(formModel.amount ?? 0);
    final fee = formatSol(formModel.fee);

    final total = (formModel.amount != null)
        ? formatSol(formModel.amount! + formModel.fee)
        : '—';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REVIEW DELIVERY',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    'Destination Wallet:',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    destination,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text('Delay:', style: TextStyle(color: Colors.grey[700])),
                  Text(
                    delayText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Divider(thickness: 1.2, color: Colors.grey),

                  const SizedBox(height: 18),

                  Text(
                    'Transferring:',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$amount SOL',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Estimated Fee:',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$fee SOL',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Divider(thickness: 1.2, color: Colors.grey),

                  const SizedBox(height: 18),
                  Text(
                    'Total Transferring + Fee:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '~$total SOL',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Fixed bottom button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('SEND SKRAMBLED'),
            ),
          ),
        ],
      ),
    );
  }
}
