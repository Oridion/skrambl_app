import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/models/send_form_model.dart';
import 'package:skrambl_app/ui/send/screens/standard/standard_sending_scren.dart';
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

  String _short(String s) {
    if (s.length <= 14) return s;
    return '${s.substring(0, 6)}…${s.substring(s.length - 6)}';
  }

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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review & Send', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              // Amount
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
                          Text('Amount', style: t.labelLarge?.copyWith(color: Colors.black54)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${formatSol(amount)} SOL',
                                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              if (usdStr != null) ...[
                                const SizedBox(width: 8),
                                Text('• $usdStr', style: t.bodyMedium?.copyWith(color: Colors.black54)),
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

              // Destination
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destination', style: t.labelLarge?.copyWith(color: Colors.black54)),
                          const SizedBox(height: 6),
                          SelectableText(
                            dest.isEmpty ? '—' : _short(dest),
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy address',
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: dest.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(ClipboardData(text: dest));
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied'),
                                  duration: Duration(milliseconds: 1200),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
              // Optional memo
              // if ((widget.form.memo ?? '').isNotEmpty) ...[
              //   const SizedBox(height: 14),
              //   Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       border: Border.all(color: Colors.black12),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text('Memo', style: t.labelLarge?.copyWith(color: Colors.black54)),
              //         const SizedBox(height: 6),
              //         Text(widget.form.memo!, style: t.bodyMedium),
              //       ],
              //     ),
              //   ),
              // ],

              //const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canContinue ? _goNext : null,
                  icon: const Icon(Icons.vpn_key_rounded, size: 18),
                  label: Text(_pushing ? 'Opening Seed Vault…' : 'Sign with Seed Vault'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
