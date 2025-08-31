import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/providers/network_fee_provider.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';
import 'package:skrambl_app/solana/universe/universe_service.dart';
import 'package:skrambl_app/ui/send/helpers/fee_estimator.dart';
import 'package:skrambl_app/ui/send/helpers/hop_estimator.dart';
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
  // ---- State ----
  late final TextEditingController _amountController;

  double? _amountSol = 0;
  int _delaySeconds = 0;
  bool _extendedDelay = false; // false = 0..60m, true = 0..24h

  // fees from Universe (lamports)
  int? _baseFeeLamports;
  int? _incrementFeeLamports;
  bool _loadingFees = true;

  // derived
  double _privacyFeeSol = 0; // cached for UI (derived)
  String? _errorText;
  bool _isNextLoading = false;

  Timer? _debounce;

  // ---- Lifecycle ----
  @override
  void initState() {
    super.initState();

    _amountSol = widget.formModel.amount;
    _delaySeconds = widget.formModel.delaySeconds;
    _amountController = TextEditingController(text: _amountSol?.toString() ?? '');

    _fetchUniverse(); // async, will call _recalc when done

    // Initial compute + listen to text changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalc(); // compute with initial values

      _amountController.addListener(() {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 120), _recalc);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  // ---- Data fetch ----
  Future<void> _fetchUniverse() async {
    try {
      skrLogger.i('Fetching Universe');
      final universe = await fetchUniverseAccount();
      if (!mounted) return;
      if (universe != null) {
        setState(() {
          _baseFeeLamports = universe.fee.toInt(); // store as int
          _incrementFeeLamports = universe.increment.toInt();
          _loadingFees = false;
        });
      } else {
        setState(() => _loadingFees = false);
      }
      _recalc();
    } catch (e) {
      skrLogger.e('Error fetching universe: $e');
      if (!mounted) return;
      setState(() => _loadingFees = false);
      _recalc();
    }
  }

  // ---- Helpers ----
  String get delayText {
    if (_delaySeconds == 0) return 'Immediate';

    final minutesTotal = _delaySeconds ~/ 60;
    final hours = minutesTotal ~/ 60;
    final minutes = minutesTotal % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String get etaText {
    if (_delaySeconds == 0) return 'Now';

    final now = DateTime.now();
    final eta = now.add(Duration(seconds: _delaySeconds));

    // Compare days (ignore time) to say Today/Tomorrow/Weekday/etc.
    DateTime dOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    final today = dOnly(now);
    final etaDay = dOnly(eta);
    final dayDiff = etaDay.difference(today).inDays;

    final time = DateFormat.jm().format(eta); // e.g., 2:37 PM

    if (dayDiff == 0) return 'Today $time';
    if (dayDiff == 1) return 'Tomorrow $time';
    if (dayDiff > 1 && dayDiff < 7) {
      return '${DateFormat.E().format(eta)} $time'; // Mon 2:37 PM
    }
    return '${DateFormat.MMMd().format(eta)} $time'; // Sep 3 2:37 PM
  }

  // Max send (keeps SOL for fees)
  double _computeMaxSendableSol({
    required double walletBalanceSol,
    required double privacyFeeSol,
    required int networkFeeLamports,
  }) {
    final netFeeSol = networkFeeLamports / AppConstants.lamportsPerSol;
    final max = walletBalanceSol - (privacyFeeSol + netFeeSol);
    return max > 0 ? max : 0;
  }

  // ---- Core recompute ----
  void _recalc() {
    // reactive reads (don’t keep references)
    final wallet = context.read<WalletProvider>();
    final networkFeeLamports = context.read<NetworkFeeProvider>().fee;

    // amount parse
    final text = _amountController.text.trim();
    final parsed = text.isEmpty ? null : double.tryParse(text);

    // delay fee
    final delayLamports = calculateDelayFeeLamports(_delaySeconds, _baseFeeLamports, _incrementFeeLamports);
    final delaySol = delayLamports / AppConstants.lamportsPerSol;

    // total for validation
    final netFeeSol = networkFeeLamports / AppConstants.lamportsPerSol;
    final total = (parsed ?? 0) + delaySol + netFeeSol;

    String? error;
    if (parsed == null) {
      error = null; // don’t complain if field is empty
    } else if (parsed <= 0) {
      error = 'Please enter a valid amount';
    } else if (!wallet.isLoading && total > wallet.solBalance) {
      error = 'Total (amount + fees) exceeds balance';
    }

    if (!mounted) return;
    setState(() {
      _amountSol = parsed;
      _privacyFeeSol = delaySol;
      _errorText = error;
    });
  }

  void _setExtended(bool v) {
    setState(() {
      _extendedDelay = v;
      final maxSecs = _extendedDelay ? 24 * 60 * 60 : 60 * 60; // 86400 or 3600
      if (_delaySeconds > maxSecs) _delaySeconds = maxSecs; // clamp if needed
    });
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    // watch things that, when changed, should trigger a recompute
    final isBalanceLoading = context.select<WalletProvider, bool>((w) => w.isLoading);
    final walletBalanceSol = context.select<WalletProvider, double>((w) => w.solBalance);
    final networkFeeLamports = context.select<NetworkFeeProvider, int>((p) => p.fee);
    final solUsd = context.select<PriceProvider, double?>((p) => p.solUsd);
    // if network fee or wallet balance changed, we want derived validation to update
    // trigger recompute cheaply (no text change)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // only if mounted and not during loading
      if (mounted) _recalc();
    });

    void fillMax() {
      final maxSol = _computeMaxSendableSol(
        walletBalanceSol: walletBalanceSol,
        privacyFeeSol: _privacyFeeSol,
        networkFeeLamports: networkFeeLamports,
      );
      _amountController.text = maxSol.toStringAsFixed(6);
    }

    final isValid = _amountSol != null && _amountSol! >= 0.000001 && _errorText == null && !isBalanceLoading;
    final amount = _amountSol ?? 0;
    final totalForHeader = amount + (_loadingFees ? 0 : _privacyFeeSol);

    Widget footer = Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(onPressed: widget.onBack, child: const Text('Back')),
          ElevatedButton(
            onPressed: (isValid && !_isNextLoading)
                ? () async {
                    FocusScope.of(context).unfocus();
                    setState(() => _isNextLoading = true);

                    final amt = _amountSol ?? 0;
                    final delay = _delaySeconds;
                    final feeSol = _privacyFeeSol;

                    if (!mounted) return;
                    await Future.wait([Future.delayed(const Duration(milliseconds: 800))]);

                    widget.formModel
                      ..amount = amt
                      ..delaySeconds = delay
                      ..fee = feeSol
                      ..solUsdPrice = (solUsd != null && solUsd > 0 ? solUsd : null);

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
              duration: const Duration(milliseconds: 220),
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
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if keyboard is open
        double inset = MediaQuery.viewInsetsOf(context).bottom;
        if (inset == 0) {
          inset = View.of(context).viewInsets.bottom;
        }
        final keyboardIsOpen = inset > 0;

        final hops = estimateHops(_delaySeconds);

        //skrLogger.i("Keyboard open $keyboardIsOpen");
        return Column(
          children: [
            AmountHeader(
              totalSol: totalForHeader,
              amountSol: amount,
              privacyFeeSol: _loadingFees ? null : _privacyFeeSol,
              loadingFees: _loadingFees,
              solUsdPrice: solUsd,
            ),

            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
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
                            solUsdPrice: solUsd,
                            amount: _amountSol,
                            walletBalance: walletBalanceSol,
                            isBalanceLoading: isBalanceLoading,
                            radius: BorderRadius.circular(6),
                            errorText: _errorText,
                            onMaxPressed: fillMax,
                          ),
                          const SizedBox(height: 26),

                          //Delay
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacityCompat(0.6),
                              border: Border.all(color: const Color.fromARGB(255, 143, 143, 143), width: 1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + range toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Delay amount',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        const Text('24h', style: TextStyle(fontSize: 12)),
                                        SizedBox(width: 3),
                                        SizedBox(
                                          width: 40,
                                          height: 28,
                                          child: FittedBox(
                                            fit: BoxFit.fill,
                                            child: Switch(
                                              value: _extendedDelay,
                                              onChanged: _setExtended,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'By setting a delay, your transfer is routed through multiple intermediate accounts. Longer delays result in more hops, providing stronger transaction obfuscation',
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
                                    max: _extendedDelay ? 24 * 60 * 60 : 60 * 60, // seconds
                                    divisions: _extendedDelay ? (24 * 60 * 60) ~/ 300 : 12, // 5-min steps
                                    value: _delaySeconds.clamp(0, _extendedDelay ? 86400 : 3600).toDouble(),
                                    label: delayText, // you already format this
                                    onChanged: (v) {
                                      setState(() => _delaySeconds = v.round()); // keep seconds
                                      _recalc();
                                    },
                                    onChangeEnd: (_) => HapticFeedback.selectionClick(),
                                  ),
                                ),
                                // Tick labels adapt to the range
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: _extendedDelay
                                        ? const [
                                            Text('0h', style: TextStyle(fontSize: 11, color: Colors.black45)),
                                            Text('6h', style: TextStyle(fontSize: 11, color: Colors.black45)),
                                            Text(
                                              '12h',
                                              style: TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                            Text(
                                              '18h',
                                              style: TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                            Text(
                                              '24h',
                                              style: TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                          ]
                                        : const [
                                            Text('0m', style: TextStyle(fontSize: 11, color: Colors.black45)),
                                            Text(
                                              '15m',
                                              style: TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                            Text(
                                              '30m',
                                              style: TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                            Text(
                                              '45m',
                                              style: TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                            Text(
                                              '60m',
                                              style: TextStyle(fontSize: 11, color: Colors.black45),
                                            ),
                                          ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DelayChip(text: 'Delay: $delayText'),
                                    const SizedBox(width: 5),
                                    MonoChip(text: hops == 2 ? '2 hops' : '~$hops hops'),
                                    const SizedBox(width: 5),
                                    SolMonoChip(text: '${formatSol(_privacyFeeSol)} Fee'),
                                  ],
                                ),
                                SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.schedule, size: 14, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ETA: $etaText',
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) => SizeTransition(
                  sizeFactor: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: keyboardIsOpen ? const SizedBox.shrink(key: ValueKey('hidden-footer')) : footer,
              ),
            ),
          ],
        );
      },
    );
  }
}
