// lib/ui/send/screens/standard/standard_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skrambl_app/models/send_form_model.dart';
import 'package:skrambl_app/ui/send/screens/standard/standard_sending_scren.dart';
import 'package:skrambl_app/ui/send/widgets/transfer_diagram.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/formatters.dart';

class StandardSummaryScreen extends StatefulWidget {
  final SendFormModel formModel;
  final VoidCallback? onBack;

  const StandardSummaryScreen({super.key, required this.formModel, this.onBack});

  @override
  State<StandardSummaryScreen> createState() => _StandardSummaryScreenState();
}

class _StandardSummaryScreenState extends State<StandardSummaryScreen> {
  bool _pushing = false;

  String? _usd(double sol, double? price) {
    if (price == null) return null;
    final v = sol * price;
    if (v >= 100) return '\$${v.toStringAsFixed(0)}';
    if (v >= 1) return '\$${v.toStringAsFixed(2)}';
    return '\$${v.toStringAsFixed(4)}';
  }

  void _goNext() {
    if (_pushing) return;
    setState(() => _pushing = true);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => StandardSendingScreen(form: widget.formModel)),
      (route) => route.isFirst, 
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final dest = widget.formModel.destinationWallet ?? '';
    final amount = widget.formModel.amount ?? 0.0;
    final usdStr = _usd(amount, widget.formModel.solUsdPrice);
    final canContinue = dest.isNotEmpty && amount > 0;

    final onBg = Colors.black;
    final onBgMuted = const Color(0xFF636363);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review and send',
                      style: t.titleMedium?.copyWith(color: onBg, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text('Final check before you send', style: t.bodySmall?.copyWith(color: onBgMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Amount card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRANSFER AMOUNT', style: t.labelMedium?.copyWith(color: Colors.black38)),
                          SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.fromLTRB(0, 12, 0, 0),
                                child: const SolanaLogo(size: 14, color: Colors.black),
                              ),
                              const SizedBox(width: 5),
                              SizedBox(
                                height: 33,
                                child: Text(
                                  formatSol(amount, maxDecimals: 6),
                                  style: GoogleFonts.archivoBlack(fontSize: 30, color: Colors.black),
                                ),
                              ),

                              if (usdStr != null) ...[
                                const SizedBox(width: 8),

                                Transform.translate(
                                  offset: const Offset(0, 7),
                                  child: Text(
                                    usdStr,
                                    style: t.bodyMedium?.copyWith(color: Colors.black54, fontSize: 18),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Transfer diagram (source -> amount -> destination)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                  child: TransferDiagram(
                    fromLabel: 'Your wallet',
                    fromAddress: shortenPubkey(widget.formModel.userWallet!, length: 8),
                    toLabel: 'Destination',
                    toAddress: dest.isEmpty ? '—' : shortenPubkey(dest, length: 8),
                    amountSol: amount,
                    amountUsd: usdStr,
                    onCopyFrom: (widget.formModel.userWallet ?? '').isEmpty
                        ? null
                        : () => Clipboard.setData(ClipboardData(text: widget.formModel.userWallet!)),
                    onCopyTo: dest.isEmpty ? null : () => Clipboard.setData(ClipboardData(text: dest)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),

      // Fixed bottom CTA
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canContinue ? _goNext : null,
              label: Text(_pushing ? 'Opening Seed Vault…' : 'APPROVE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
