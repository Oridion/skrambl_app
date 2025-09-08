import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:expandable/expandable.dart';
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

  bool _useCustomAmount = false;
  double? _presetAmountSol; // one of [0.05, 0.1, 0.5, 1.0]
  // expanded/collapsed state for delay
  final _amountPanelController = ExpandableController(initialExpanded: true); // default open
  final _delayPanelController = ExpandableController(initialExpanded: false);
  // top of _SkrambledAmountScreenState

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

    // Keep panels mutually exclusive
    _amountPanelController.addListener(() {
      if (_amountPanelController.expanded && _delayPanelController.expanded) {
        _delayPanelController.expanded = false;
        setState(() {});
      }
    });
    _delayPanelController.addListener(() {
      if (_delayPanelController.expanded && _amountPanelController.expanded) {
        _amountPanelController.expanded = false;
        setState(() {});
      }
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
  String get delayText => getDelayText(_delaySeconds);
  String get etaText => getETAText(_delaySeconds);

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

  static const _presets = <double>[0.05, 0.1, 0.5, 1.0];

  void _selectPreset(double v) {
    setState(() {
      _useCustomAmount = false;
      _presetAmountSol = v;
    });
    _recalc();
  }

  void _enableCustom() {
    setState(() {
      _useCustomAmount = true;
      if (_presetAmountSol != null && (_amountController.text.isEmpty)) {
        // was: _amountController.text = _presetAmountSol!.toStringAsFixed(6);
        _amountController.text = formatSol(_presetAmountSol!, maxDecimals: 6);
      }
    });
  }

  /// current amount for all calculations
  double _currentAmountSol() {
    if (_useCustomAmount) {
      final parsed = double.tryParse(_amountController.text.trim());
      return parsed ?? 0;
    }
    return _presetAmountSol ?? 0; // no custom → preset or 0
  }

  void _recalc() {
    final wallet = context.read<WalletProvider>();
    final networkFeeLamports = context.read<NetworkFeeProvider>().fee;

    // delay fee
    final delayLamports = calculateDelayFeeLamports(_delaySeconds, _baseFeeLamports, _incrementFeeLamports);
    final delaySol = delayLamports / AppConstants.lamportsPerSol;

    final amountSol = _currentAmountSol();
    final netFeeSol = networkFeeLamports / AppConstants.lamportsPerSol;
    final total = amountSol + delaySol + netFeeSol;

    String? error;
    if (_useCustomAmount) {
      final text = _amountController.text.trim();
      final parsed = text.isEmpty ? null : double.tryParse(text);
      if (parsed == null) {
        error = null; // don’t nag on empty
      } else if (parsed <= 0) {
        error = 'Please enter a valid amount';
      } else if (!wallet.isLoading && total > wallet.solBalance) {
        error = 'Total (amount + fees) exceeds balance';
      }
    } else {
      // preset mode validation
      if ((_presetAmountSol ?? 0) <= 0) {
        error = '';
      } else if (!wallet.isLoading && total > wallet.solBalance) {
        error = 'Total (amount + fees) exceeds balance';
      }
    }

    if (!mounted) return;
    setState(() {
      _amountSol = _useCustomAmount ? double.tryParse(_amountController.text.trim()) : _presetAmountSol;
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
      _amountController.text = formatSol(maxSol, maxDecimals: 6);
    }

    final isValid = _amountSol != null && _amountSol! >= 0.000001 && _errorText == null && !isBalanceLoading;

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

        ///Expanded update
        final amount = _currentAmountSol();
        final totalForHeader = amount + (_loadingFees ? 0 : _privacyFeeSol);
        final isBalanceLoading = context.select<WalletProvider, bool>((w) => w.isLoading);
        final tickStyle = TextStyle(fontSize: 11, color: Colors.black54);

        /// End expanded update

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
                          // ===== Balance =====
                          if (!isBalanceLoading && walletBalanceSol > 0) ...[
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacityCompat(0.05),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Balance:',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Transform.translate(
                                      offset: Offset(0, 1),
                                      child: const SolanaLogo(size: 7, useDark: false, color: Colors.black),
                                    ),

                                    SizedBox(width: 2),
                                    Text(
                                      '${formatSol(walletBalanceSol, maxDecimals: 6)} SOL',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // ===== Send Amount (Expandable) =====
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: ExpandablePanel(
                              controller: _amountPanelController,
                              theme: const ExpandableThemeData(
                                tapHeaderToExpand: true,
                                hasIcon: true,
                                headerAlignment: ExpandablePanelHeaderAlignment.center,
                                iconColor: Colors.black87,
                              ),
                              header: Row(
                                children: [
                                  // const SolanaLogo(size: 10, useDark: false, color: Colors.black),
                                  // const SizedBox(width: 8),
                                  Text(
                                    !_useCustomAmount
                                        ? (_presetAmountSol == null || _presetAmountSol == 0)
                                              ? 'Send amount'
                                              : 'Sending: ${formatSol(_presetAmountSol!)} SOL'
                                        : (_amountSol == null || _amountSol == 0)
                                        ? 'Send amount'
                                        : 'Sending: ${formatSol(_amountSol!)} SOL',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),

                              collapsed: const SizedBox.shrink(),
                              expanded: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ==== Presets OR Custom (your existing AnimatedSwitcher) ====
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: !_useCustomAmount
                                        ? Column(
                                            key: const ValueKey('presets'),
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 0,
                                                children: _presets.map((p) {
                                                  final selected = _presetAmountSol == p;
                                                  return SizedBox(
                                                    width:
                                                        (MediaQuery.of(context).size.width - 30 * 2 - 8) / 2,
                                                    child: ChoiceChip(
                                                      label: Center(
                                                        child: Text(
                                                          '${p.toStringAsFixed(p < 0.1 ? 2 : 1)} SOL',
                                                        ),
                                                      ),
                                                      selected: selected,
                                                      onSelected: (_) => _selectPreset(p),
                                                      selectedColor: Colors.black,
                                                      labelStyle: TextStyle(
                                                        color: selected ? Colors.white : Colors.black87,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          color: selected ? Colors.black : Colors.black26,
                                                        ),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),

                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton.icon(
                                                  onPressed: _enableCustom,
                                                  icon: const Icon(
                                                    Icons.tune,
                                                    size: 16,
                                                    color: Colors.black87,
                                                  ),
                                                  label: const Text(
                                                    'Custom amount',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    side: const BorderSide(color: Colors.black45),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                                  ),
                                                ),
                                              ),
                                              if (_errorText != null) ...[
                                                const SizedBox(height: 4),
                                                Align(
                                                  alignment: Alignment.center, // 👈 right align
                                                  child: Text(
                                                    _errorText!,
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(255, 167, 35, 26),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          )
                                        : Column(
                                            key: const ValueKey('custom'),
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
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton.icon(
                                                  onPressed: () => setState(() => _useCustomAmount = false),

                                                  label: const Text(
                                                    'Back to presets',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    side: const BorderSide(color: Colors.black26),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ===== Delay (Expandable) =====
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 6, 0, 6),

                            child: ExpandablePanel(
                              controller: _delayPanelController,
                              theme: const ExpandableThemeData(
                                tapHeaderToExpand: true,
                                tapBodyToCollapse: false,
                                hasIcon: true,
                                headerAlignment: ExpandablePanelHeaderAlignment.center,
                                iconColor: Colors.black87,
                              ),
                              header: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      _delaySeconds == 0
                                          ? 'Immediate delivery'
                                          : 'Delay: ${getDelayText(_delaySeconds)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                    const Spacer(),
                                    if (_delaySeconds > 0)
                                      Text(
                                        estimateHops(_delaySeconds) == 2
                                            ? '2 hops'
                                            : '~${estimateHops(_delaySeconds)} hops',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                  ],
                                ),
                              ),
                              collapsed: const SizedBox.shrink(), // nothing when collapsed
                              expanded: Container(
                                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacityCompat(0.6),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 143, 143, 143),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 24h toggle
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Delivery delay',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            const Text('24h', style: TextStyle(fontSize: 12)),
                                            const SizedBox(width: 3),
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
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Longer delays route through more hops for stronger privacy.',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                                    ),
                                    const SizedBox(height: 16),

                                    // Slider (unchanged logic)
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
                                        max: _extendedDelay ? 24 * 60 * 60 : 60 * 60,
                                        divisions: _extendedDelay ? (24 * 60 * 60) ~/ 300 : 12,
                                        value: _delaySeconds
                                            .clamp(0, _extendedDelay ? 86400 : 3600)
                                            .toDouble(),
                                        label: getDelayText(_delaySeconds),
                                        onChanged: (v) {
                                          setState(() => _delaySeconds = v.round());
                                          _recalc();
                                        },
                                        onChangeEnd: (_) => HapticFeedback.selectionClick(),
                                      ),
                                    ),

                                    // Ticks & chips
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: _extendedDelay
                                            ? [
                                                Text('0h', style: tickStyle),
                                                Text('6h', style: tickStyle),
                                                Text('12h', style: tickStyle),
                                                Text('18h', style: tickStyle),
                                                Text('24h', style: tickStyle),
                                              ]
                                            : [
                                                Text('0m', style: tickStyle),
                                                Text('15m', style: tickStyle),
                                                Text('30m', style: tickStyle),
                                                Text('45m', style: tickStyle),
                                                Text('60m', style: tickStyle),
                                              ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        DelayChip(text: 'Delay: ${getDelayText(_delaySeconds)}'),
                                        const SizedBox(width: 5),
                                        MonoChip(
                                          text: estimateHops(_delaySeconds) == 2
                                              ? '2 hops'
                                              : '~${estimateHops(_delaySeconds)} hops',
                                        ),
                                        const SizedBox(width: 5),
                                        SolMonoChip(text: '${formatSol(_privacyFeeSol)} Fee'),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.schedule, size: 13, color: Colors.black54),
                                        const SizedBox(width: 3),
                                        Text(
                                          'ETA: ${getETAText(_delaySeconds)}',
                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'ETA is based on on-chain finalization; actual timing can vary.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontStyle: FontStyle.italic,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
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
