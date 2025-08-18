import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PodActionsBar extends StatelessWidget {
  final String? pda;
  final String? signature; // launch signature if available
  const PodActionsBar({super.key, required this.pda, required this.signature});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PrimaryButton(
          icon: Icons.open_in_new,
          label: 'Open in Explorer',
          onPressed: () async {
            // Prefer Solscan (or make this configurable)
            final url = signature != null && signature!.isNotEmpty
                ? Uri.parse('https://solscan.io/tx/${signature!}')
                : pda != null && pda!.isNotEmpty
                ? Uri.parse('https://solscan.io/account/${pda!}')
                : null;
            if (url != null) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
        // const SizedBox(width: 12),
        // _SecondaryButton(
        //   icon: Icons.description_outlined,
        //   label: 'Copy Summary',
        //   onPressed: () async {
        //     final summary = StringBuffer()
        //       ..writeln('SKRAMBL Delivery Summary')
        //       ..writeln('— — — — — — — — — — — —')
        //       ..writeln('PDA: ${pda ?? 'N/A'}')
        //       ..writeln('Signature: ${signature ?? 'N/A'}');
        //     await Clipboard.setData(ClipboardData(text: summary.toString()));
        //     if (context.mounted) {
        //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Summary copied')));
        //     }
        //   },
        // ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

// class _SecondaryButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onPressed;
//   const _SecondaryButton({required this.icon, required this.label, required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 18),
//       label: Text(label),
//       style: OutlinedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
// }
