import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/providers/network_fee_provider.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';
import 'package:skrambl_app/services/price_service.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/solana/universe/universe_service.dart';
import 'package:skrambl_app/ui/send/helpers/fee_estimator.dart';
import 'package:skrambl_app/ui/send/widgets/amount_header.dart';
import 'package:skrambl_app/ui/send/widgets/amount_input.dart';
import 'package:skrambl_app/ui/send/widgets/slider_shape.dart';
import 'package:skrambl_app/ui/shared/chips.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/logger.dart';

import '../../../../models/send_form_model.dart';

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
  bool _isNextLoading = false;
  double? _amount;
  int _delaySeconds = 30;
  String? _errorText;
  BigInt? _baseFee;
  BigInt? _incrementFee;
  bool _loadingFees = true;

  static const double _minAmount = 0.000001;

  final rpc = SolanaClientService().rpcClient;

  @override
  void initState() {
    super.initState();
    _amount = widget.formModel.amount;
    _delaySeconds = widget.formModel.delaySeconds;
    _amountController = TextEditingController(text: _amount?.toString() ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallet = context.read<WalletProvider>();
      final netFeeSol = context.read<NetworkFeeProvider>().fee / AppConstants.lamportsPerSol;

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
        final privacyFee = calculateFee(_delaySeconds);
        final total = (parsed ?? 0) + privacyFee + netFeeSol;

        String? error;
        if (parsed == null || parsed <= 0) {
          error = 'Please enter a valid amount';
        } else {
          final walletBalance = wallet.solBalance;
          final isLoading = wallet.isLoading;
          if (!isLoading && total > walletBalance) {
            error = 'Total (amount + fees) exceeds balance';
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
    final feeSol = feeLamports / BigInt.from(AppConstants.lamportsPerSol);
    return feeSol.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final fee = calculateFee(_delaySeconds);
    final balanceProvider = context.watch<WalletProvider>();
    final isBalanceLoading = balanceProvider.isLoading;
    final networkFeeLamports = context.select<NetworkFeeProvider, int>((p) => p.fee);
    final privacyFeeSol = calculateFee(_delaySeconds);
    final walletBalanceSol = context.watch<WalletProvider>().solBalance;

    void fillMax() {
      final maxSol = computeMaxSendableSol(
        walletBalanceSol: walletBalanceSol,
        privacyFeeSol: privacyFeeSol,
        networkFeeLamports: networkFeeLamports,
      );
      _amountController.text = maxSol.toStringAsFixed(6);
    }

    final isValid = _amount != null && _amount! >= _minAmount && _errorText == null && !isBalanceLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            AmountHeader(
              amount: _amount,
              delaySeconds: _delaySeconds,
              calcFee: calculateFee,
              solUsdPrice: widget.formModel.solUsdPrice,
              loadingFees: _loadingFees,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 26, 30, 26),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 200),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AmountInput(
                          controller: _amountController,
                          solUsdPrice: widget.formModel.solUsdPrice,
                          amount: _amount,
                          walletBalance: walletBalanceSol,
                          isBalanceLoading: isBalanceLoading,
                          radius: BorderRadius.circular(6),
                          errorText: _errorText,
                          onMaxPressed: fillMax, // <-- single source of truth
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacityCompat(0.6), // or Theme.of(context).cardColor
                            border: Border.all(color: const Color.fromARGB(255, 143, 143, 143), width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delay amount',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Adding a delay routes your transfer through extra stops, making it harder to trace and enhancing privacy',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                              ),
                              const SizedBox(height: 20),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 16,
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
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DelayChip(text: 'Delay: $delayText'),
                                  const SizedBox(width: 8),
                                  MonoChip(text: '${formatSol(calculateFee(_delaySeconds))} Fee'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // tiny ticks
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
                    onPressed: (isValid && !_isNextLoading)
                        ? () async {
                            // 1) Dismiss keyboard immediately
                            FocusScope.of(context).unfocus();

                            setState(() => _isNextLoading = true);

                            final amt = _amount ?? 0;
                            final delay = _delaySeconds;
                            final feeSol = fee; // already computed above

                            // 2) Do work in parallel with a small UX delay (~2s)
                            double? priceUsdPerSol;
                            await Future.wait([
                              Future.delayed(const Duration(seconds: 1)),
                              (() async {
                                try {
                                  priceUsdPerSol = await fetchSolPriceUsd();
                                } catch (_) {
                                  // leave as null on failure
                                }
                              })(),
                            ]);

                            if (!mounted) return;

                            // 3) Persist form values
                            widget.formModel
                              ..amount = amt
                              ..delaySeconds = delay
                              ..fee = feeSol
                              ..solUsdPrice = priceUsdPerSol;

                            // 4) Stop spinner and move on
                            setState(() => _isNextLoading = false);
                            widget.onNext();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
                      child: _isNextLoading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Next', key: ValueKey('label')),
                    ),
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
