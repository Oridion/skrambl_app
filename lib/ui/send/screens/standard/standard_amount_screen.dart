// lib/ui/send/standard/standard_amount_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:skrambl_app/models/send_form_model.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/services/price_service.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class StandardAmountScreen extends StatefulWidget {
  final SendFormModel formModel;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const StandardAmountScreen({super.key, required this.formModel, required this.onNext, this.onBack});

  @override
  State<StandardAmountScreen> createState() => _StandardAmountScreenState();
}

class _StandardAmountScreenState extends State<StandardAmountScreen> {
  late final TextEditingController _amountCtrl;
  String? _errorText;
  double? _amount;

  static const double _minAmount = 0.000001;

  @override
  void initState() {
    super.initState();
    _amount = widget.formModel.amount;
    _amountCtrl = TextEditingController(text: _amount?.toString() ?? '');
    _amountCtrl.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountCtrl.removeListener(_onAmountChanged);
    _amountCtrl.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final balance = context.read<WalletBalanceProvider>().solBalance;
    final isLoading = context.read<WalletBalanceProvider>().isLoading;

    final text = _amountCtrl.text.trim();
    if (text.isEmpty) {
      setState(() {
        _amount = null;
        _errorText = null;
      });
      return;
    }

    final parsed = double.tryParse(text);
    String? err;
    if (parsed == null || parsed <= 0) {
      err = 'Please enter a valid amount';
    } else if (!isLoading && parsed > balance) {
      err = 'Amount exceeds wallet balance';
    }

    setState(() {
      _amount = parsed;
      _errorText = err;
    });
  }

  String _usd(double sol) {
    final p = widget.formModel.solUsdPrice;
    if (p == null) return '';
    final v = sol * p;
    if (v >= 100) return '\$${v.toStringAsFixed(0)}';
    if (v >= 1) return '\$${v.toStringAsFixed(2)}';
    return '\$${v.toStringAsFixed(4)}';
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    // refresh price once here so summary has it
    double? priceUsdPerSol;
    try {
      priceUsdPerSol = await fetchSolPriceUsd();
    } catch (_) {}

    widget.formModel
      ..amount = _amount
      ..solUsdPrice = priceUsdPerSol;

    if (!mounted) return;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final balanceProvider = context.watch<WalletBalanceProvider>();
    final walletBalance = balanceProvider.solBalance;
    final isBalanceLoading = balanceProvider.isLoading;

    final hasAmount = _amount != null && _amount! > 0;
    final isValid = hasAmount && _amount! >= _minAmount && _errorText == null && !isBalanceLoading;

    final radius = BorderRadius.circular(10);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Simple header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              decoration: BoxDecoration(
                color: Colors.black,
                border: const Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacityCompat(0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
                    child: Text(
                      hasAmount ? '${formatSol(_amount!)} SOL' : '0 SOL',
                      key: ValueKey('${_amount ?? 0}'),
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  if (hasAmount && widget.formModel.solUsdPrice != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _usd(_amount!),
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacityCompat(0.75)),
                    ),
                  ],
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter amount', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}'))],
                      decoration: InputDecoration(
                        labelText: 'Amount in SOL',
                        helperText: (widget.formModel.solUsdPrice != null && (_amount ?? 0) > 0)
                            ? '≈ ${_usd(_amount ?? 0)}'
                            : null,
                        helperStyle: const TextStyle(fontSize: 12, color: Colors.black54),
                        border: OutlineInputBorder(borderRadius: radius),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: radius,
                          borderSide: const BorderSide(color: Colors.black, width: 1.6),
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
                        suffixIcon: (!isBalanceLoading && walletBalance > 0)
                            ? Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFEDEDED),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  ),
                                  onPressed: () {
                                    if (walletBalance > 0) {
                                      _amountCtrl.text = walletBalance.toStringAsFixed(6);
                                    }
                                  },
                                  child: const Text(
                                    'MAX',
                                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                  ),
                                ),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(minWidth: 72),
                        errorText: _errorText,
                      ),
                    ),

                    if (!isBalanceLoading && walletBalance > 0) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                        child: Text(
                          'Balance: ${formatSol(walletBalance)} SOL',
                          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.onBack != null) TextButton(onPressed: widget.onBack, child: const Text('Back')),
                  ElevatedButton(
                    onPressed: isValid ? _continue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
