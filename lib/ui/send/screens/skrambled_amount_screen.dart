import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/services/price_service.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/solana/universe/universe_service.dart';
import 'package:skrambl_app/ui/send/widgets/glitch_header.dart';
import 'package:skrambl_app/ui/send/widgets/slider_shape.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/logger.dart';

import '../../../models/send_form_model.dart';

class SkrambledAmountScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final SendFormModel formModel;

  const SkrambledAmountScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.formModel,
  });

  @override
  State<SkrambledAmountScreen> createState() => _SkrambledAmountScreenState();
}

class _SkrambledAmountScreenState extends State<SkrambledAmountScreen> {
  late final TextEditingController _amountController;
  double? _amount;
  int _delaySeconds = 30;
  String? _errorText;
  BigInt? _baseFee;
  BigInt? _incrementFee;
  bool _loadingFees = true;

  static const int lamportsPerSol = 1000000000;
  static const double _minAmount = 0.000001;

  final rpc = SolanaClientService().rpcClient;

  @override
  void initState() {
    super.initState();
    _amount = widget.formModel.amount;
    _delaySeconds = widget.formModel.delaySeconds;
    _amountController = TextEditingController(text: _amount?.toString() ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WalletBalanceProvider>();

      _amountController.addListener(() {
        final text = _amountController.text.trim();

        if (text.isEmpty) {
          setState(() {
            _amount = null;
            _errorText = null;
          });
          return;
        }

        final parsed = double.tryParse(text);
        final fee = calculateFee(_delaySeconds);
        final total = (parsed ?? 0) + fee;

        String? error;
        if (parsed == null || parsed <= 0) {
          error = 'Please enter a valid amount';
        } else {
          final walletBalance = provider.solBalance;
          final isLoading = provider.isLoading;

          if (!isLoading && total > walletBalance) {
            error = 'Total exceeds wallet balance';
          }
        }

        setState(() {
          _amount = parsed;
          _errorText = error;
        });
      });
    });

    _fetchUniverse();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchUniverse() async {
    try {
      skrLogger.i('Fetching Universe');

      final universe = await fetchUniverseAccount();
      if (universe != null) {
        setState(() {
          _baseFee = universe.fee;
          _incrementFee = universe.increment;
          _loadingFees = false;
        });
      } else {
        setState(() => _loadingFees = false);
      }
    } catch (e) {
      skrLogger.e('Error fetching universe: $e');
      setState(() => _loadingFees = false);
    }
  }

  String get delayText {
    if (_delaySeconds == 0) return 'Immediate';
    final minutes = (_delaySeconds / 60).toStringAsFixed(0);
    return '$minutes min';
  }

  double calculateFee(int delaySeconds) {
    if (_baseFee == null || _incrementFee == null) {
      skrLogger.w('Base fee or increment fee is null');
      return 0;
    }

    final int tiers = (delaySeconds / 180).floor();
    final feeLamports = _baseFee! + (_incrementFee! * BigInt.from(tiers));
    final feeSol = feeLamports / BigInt.from(lamportsPerSol);
    return feeSol.toDouble();
  }

  Widget _buildHeader() {
    final double amount = _amount ?? 0;
    final double fee = calculateFee(_delaySeconds);
    final bool hasAmount = _amount != null && _amount! > 0;
    final double total = hasAmount ? amount + fee : 0;

    String usd(double sol) {
      final p = widget.formModel.solUsdPrice;
      if (p == null) return '';
      final v = sol * p;
      final s = v >= 100
          ? v.toStringAsFixed(0)
          : v >= 1
          ? v.toStringAsFixed(2)
          : v.toStringAsFixed(4);
      return '\$$s';
    }

    return GlitchHeader(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTIMATED TOTAL',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacityCompat(0.7), letterSpacing: 0.8),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
              child: Text(
                '${formatSol(total)} SOL',
                key: ValueKey('${total.toStringAsFixed(9)}$_delaySeconds'),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            if (hasAmount) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '(${formatSol(amount)} + ${formatSol(fee)} fee)',
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(width: 8),
                  if (widget.formModel.solUsdPrice != null)
                    Text(
                      '• ${usd(total)}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacityCompat(0.75)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fee = calculateFee(_delaySeconds);

    final balanceProvider = context.watch<WalletBalanceProvider>();
    final walletBalance = balanceProvider.solBalance;
    final isBalanceLoading = balanceProvider.isLoading;

    final isValid = _amount != null && _amount! >= _minAmount && _errorText == null && !isBalanceLoading;
    final radius = BorderRadius.circular(10);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 200),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter amount and delay',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 22),

                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')), // max 6 decimals
                          ],
                          decoration: InputDecoration(
                            labelText: 'Amount in SOL',
                            helperText: (widget.formModel.solUsdPrice != null && (_amount ?? 0) > 0)
                                ? '≈ ${((_amount ?? 0) * (widget.formModel.solUsdPrice ?? 0)).toStringAsFixed(2)} USD'
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
                            errorStyle: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFB3261E),
                              height: 1.1,
                            ),
                            suffixIcon: (!isBalanceLoading && walletBalance > 0)
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: const Color(0xFFEDEDED),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      onPressed: () {
                                        final feeNow = calculateFee(_delaySeconds);
                                        final max = walletBalance - feeNow;
                                        if (max > 0) _amountController.text = max.toStringAsFixed(6);
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
                        const SizedBox(height: 38),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _DelayChip(text: 'Delay: $delayText'),
                            const SizedBox(width: 8),
                            _MonoChip(text: '${calculateFee(_delaySeconds).toStringAsFixed(3)} SOL fee'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 20,
                            activeTrackColor: const Color.fromARGB(221, 60, 60, 60),
                            inactiveTrackColor: const Color.fromARGB(255, 211, 211, 211),
                            thumbShape: const SquareSliderThumbShape(size: 35),
                            thumbColor: Colors.black,
                            overlayShape: SliderComponentShape.noOverlay,
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                          ),
                          child: Slider(
                            min: 0,
                            max: 3600,
                            divisions: 12, // 0,5,10,...,60 min steps
                            value: _delaySeconds.toDouble(),
                            label: delayText,
                            onChanged: (v) => setState(() => _delaySeconds = v.round()),
                            onChangeEnd: (_) => HapticFeedback.selectionClick(),
                          ),
                        ),

                        // tiny ticks
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('0m', style: TextStyle(fontSize: 11, color: Colors.black45)),
                              Text('15m', style: TextStyle(fontSize: 11, color: Colors.black45)),
                              Text('30m', style: TextStyle(fontSize: 11, color: Colors.black45)),
                              Text('45m', style: TextStyle(fontSize: 11, color: Colors.black45)),
                              Text('60m', style: TextStyle(fontSize: 11, color: Colors.black45)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: widget.onBack, child: const Text('Back')),
                  ElevatedButton(
                    onPressed: isValid
                        ? () async {
                            final amt = _amount ?? 0;
                            final delay = _delaySeconds;
                            final feeLamports = fee;

                            FocusScope.of(context).unfocus();

                            double? priceUsdPerSol;
                            try {
                              priceUsdPerSol = await fetchSolPriceUsd(); // one HTTP call
                            } catch (_) {}

                            if (!context.mounted) return;

                            widget.formModel
                              ..amount = amt
                              ..delaySeconds = delay
                              ..fee = feeLamports
                              ..solUsdPrice = priceUsdPerSol; // <— store the numeric price once

                            widget.onNext();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DelayChip extends StatelessWidget {
  final String text;
  const _DelayChip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MonoChip extends StatelessWidget {
  final String text;
  const _MonoChip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
    );
  }
}
