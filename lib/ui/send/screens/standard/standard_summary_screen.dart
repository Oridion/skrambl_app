// lib/ui/send/screens/standard/standard_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String _short(String s) => s.length <= 14 ? s : '${s.substring(0, 6)}…${s.substring(s.length - 6)}';

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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => StandardSendingScreen(form: widget.formModel)))
        .whenComplete(() => mounted ? setState(() => _pushing = false) : null);
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
                      style: t.titleMedium?.copyWith(
                        color: onBg,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Transfer Amount', style: t.labelLarge?.copyWith(color: Colors.black54)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const SolanaLogo(size: 18, color: Colors.black),
                              const SizedBox(width: 10),
                              Text(
                                formatSol(amount),
                                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 30),
                              ),
                              const SizedBox(width: 8),
                              if (usdStr != null) ...[
                                Text('•', style: t.bodyMedium?.copyWith(color: Colors.black54, fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(
                                  usdStr,
                                  style: t.bodyMedium?.copyWith(color: Colors.black54, fontSize: 20),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Transfer diagram (source -> amount -> destination)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                  child: TransferDiagram(
                    fromLabel: 'Your wallet',
                    fromAddress: _short(widget.formModel.userWallet ?? '—'),
                    toLabel: 'Destination',
                    toAddress: dest.isEmpty ? '—' : _short(dest),
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
