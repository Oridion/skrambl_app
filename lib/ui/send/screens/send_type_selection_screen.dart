import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/ui/send/widgets/type_choice_card.dart';
import 'package:skrambl_app/utils/colors.dart';
import '../../../models/send_form_model.dart';

class SendTypeSelectionScreen extends StatelessWidget {
  final VoidCallback onNext;
  final SendFormModel formModel;

  const SendTypeSelectionScreen({super.key, required this.onNext, required this.formModel});

  @override
  Widget build(BuildContext context) {
    final brandTan = const Color.fromARGB(255, 237, 237, 237); // SKRAMBL tan
    final card = const Color.fromARGB(255, 238, 238, 238);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 14, 25, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              // Header
              Text(
                'Choose how to send',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Standard send is near-instant you are familar with zero fees collected. SKRAMBLED adds distance between you and the recipient.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacityCompat(0.72), height: 1.25),
              ),
              const SizedBox(height: 28),

              // SKRAMBLED (recommended)
              ChoiceCard(
                title: 'SKRAMBLED',
                icon: Icons.auto_awesome,
                leadText: 'Route through Oridion to obscure origins.',
                bulletPoints: const [
                  'Adds separation layer',
                  'Harder to trace backward',
                  'Optional delay window for added padding',
                ],
                etaText: '< 1 Min + Delay',
                accent: brandTan,
                background: card,
                badgeText: 'Recommended',
                isHighlighted: true, // <-- highlight this one
                onSelected: () async {
                  HapticFeedback.selectionClick();
                  formModel.isSkrambled = true;
                  onNext();
                },
              ),
              const SizedBox(height: 24),

              // STANDARD
              ChoiceCard(
                title: 'Standard',
                icon: Icons.flash_on,
                leadText: 'Instant send with zero fees',
                bulletPoints: const ['Zero fees collected', 'Standard fast delivery', 'No obfuscation'],
                etaText: 'Near-instant',
                accent: Colors.white24,
                background: card,
                onSelected: () async {
                  HapticFeedback.selectionClick();
                  formModel.isSkrambled = false;
                  onNext();
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
