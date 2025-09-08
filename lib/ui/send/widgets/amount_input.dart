// lib/ui/shared/amount_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final double? solUsdPrice;
  final double? amount;
  final double walletBalance; // still shown as helper text
  final bool isBalanceLoading;
  final String? errorText;
  final BorderRadius radius;

  /// Parent computes MAX (in lamports-safe way) and sets controller.text
  final VoidCallback? onMaxPressed;

  const AmountInput({
    super.key,
    required this.controller,
    required this.solUsdPrice,
    required this.amount,
    required this.walletBalance,
    required this.isBalanceLoading,
    required this.radius,
    this.errorText,
    this.onMaxPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          autofocus: false,
          controller: controller,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}'))],
          decoration: InputDecoration(
            fillColor: Colors.white.withOpacityCompat(0.6),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            prefix: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(width: 2),
                SolanaLogo(size: 14, color: Colors.black),
                SizedBox(width: 8),
              ],
            ),
            helperText: (solUsdPrice != null && (amount ?? 0) > 0)
                ? '≈ \$${((amount ?? 0) * (solUsdPrice ?? 0)).toStringAsFixed(2)} USD'
                : null,
            helperStyle: const TextStyle(fontSize: 12, color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: Color.fromARGB(255, 143, 143, 143), width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: Color.fromARGB(255, 143, 143, 143), width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.6),
            ),
            errorStyle: const TextStyle(fontSize: 12.5, color: Color(0xFFB3261E), height: 1.1),

            // MAX is delegated to parent
            suffixIcon: (!isBalanceLoading && walletBalance > 0 && onMaxPressed != null)
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                      ),
                      onPressed: onMaxPressed,
                      child: const Text(
                        'MAX',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 72),
            errorText: errorText,
          ),
        ),

        SizedBox(height: 8),

        // 🚨 Disclaimer about traceability when using custom amount
        const Text(
          'Using a custom amount may reduce your privacy. '
          'Common preset amounts are harder to trace, but unique values can be fingerprinted '
          'and linked to your activity.',
          style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic, height: 1.3),
        ),
      ],
    );
  }
}
