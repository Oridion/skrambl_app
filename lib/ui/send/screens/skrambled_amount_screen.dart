import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/solana/universe/universe_service.dart';
import 'package:skrambl_app/ui/send/widgets/glitch_header.dart';
import 'package:skrambl_app/ui/send/widgets/slider_shape.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/logger.dart';

import '../send_form_model.dart';

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

    return GlitchHeader(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ESTIMATED TOTAL COST',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              '${formatSol(total)} SOL',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (hasAmount) ...[
              const SizedBox(height: 4),
              Text(
                '(${formatSol(amount)} +${formatSol(fee)} FEE)',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
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

    final isValid =
        _amount != null &&
        _amount! >= _minAmount &&
        _errorText == null &&
        !isBalanceLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 200,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter amount and delay',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Amount (SOL)',
                            border: const OutlineInputBorder(),
                            // Customize border when error occurs 👇
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 175, 33, 33),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),

                            // Optional: border when focused & error is shown
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 175, 33, 33),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),

                            // Adjust the error message text style
                            errorStyle: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 175, 33, 33),
                              height: 1.2, // tight vertical spacing
                            ),
                            errorText: _errorText,
                            suffixIcon: (!isBalanceLoading && walletBalance > 0)
                                ? TextButton(
                                    onPressed: () {
                                      final fee = calculateFee(_delaySeconds);
                                      final max = walletBalance - fee;
                                      if (max > 0) {
                                        _amountController.text = max
                                            .toStringAsFixed(6);
                                      }
                                    },
                                    child: const Text('MAX'),
                                  )
                                : null,
                          ),
                        ),
                        if (!isBalanceLoading && walletBalance > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Balance: ${formatSol(walletBalance)} SOL',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 38),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Delay: $delayText',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '(${calculateFee(_delaySeconds).toStringAsFixed(3)} FEE)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 65, 65, 65),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 14.0,
                            activeTrackColor: Colors.black54,
                            inactiveTrackColor: Colors.grey.shade100,
                            trackShape: const RoundedRectSliderTrackShape(),
                            thumbShape: const SquareSliderThumbShape(
                              size: 25,
                            ), // 👈 use boxy thumb,
                            thumbColor: Colors.black,
                            overlayShape: SliderComponentShape.noOverlay,
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                          ),
                          child: Slider(
                            min: 0,
                            max: 3600,
                            divisions: 12,
                            value: _delaySeconds.toDouble(),
                            label: delayText,
                            onChanged: (value) {
                              setState(() => _delaySeconds = value.round());
                            },
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: widget.onBack,
                              child: const Text('Back'),
                            ),
                            ElevatedButton(
                              onPressed: isValid
                                  ? () {
                                      widget.formModel.amount = _amount;
                                      widget.formModel.delaySeconds =
                                          _delaySeconds;
                                      widget.formModel.fee = fee;
                                      FocusScope.of(
                                        context,
                                      ).unfocus(); // Dismiss keyboard
                                      widget.onNext();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
