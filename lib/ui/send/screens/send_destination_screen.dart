// lib/screens/destination/skrambled_destination_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';
import 'package:skrambl_app/ui/burners/burner_tile.dart';
import 'package:skrambl_app/ui/burners/create_burner_sheet.dart';
import 'package:skrambl_app/ui/burners/empty_burner_state.dart';
import 'package:skrambl_app/models/send_form_model.dart';
import 'package:skrambl_app/ui/send/widgets/destination_tab_header.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/launcher.dart';

enum DestinationMode { address, burner }

class SendDestinationScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final SendFormModel formModel;

  /// Inject data flow so this widget is UI-only and reusable.
  final Future<List<BurnerWallet>> Function() fetchBurners;
  final Future<BurnerWallet> Function(String label) createBurner;

  const SendDestinationScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.formModel,
    required this.fetchBurners,
    required this.createBurner,
  });

  @override
  State<SendDestinationScreen> createState() => _SendDestinationScreenState();
}

class _SendDestinationScreenState extends State<SendDestinationScreen> with TickerProviderStateMixin {
  // Address mode
  late final TextEditingController _addressCtrl;
  String? _error;
  bool _isValid = false;
  Timer? _debounce;
  String? _lastPersisted;

  // Burner mode
  List<BurnerWallet> _burners = [];
  String? _selectedBurnerAddress;
  bool _loadingBurners = true;

  // Tabs
  late final TabController _tabCtrl;
  DestinationMode _mode = DestinationMode.address;

  @override
  void initState() {
    super.initState();

    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      setState(() {
        _mode = _tabCtrl.index == 0 ? DestinationMode.address : DestinationMode.burner;
      });
    });

    _addressCtrl = TextEditingController(text: widget.formModel.destinationWallet ?? '');

    _addressCtrl.addListener(() {
      final current = _addressCtrl.text.trim();
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        final valid = isSolanaAddress(current);
        setState(() {
          _isValid = valid;
          if (_error != null && valid) _error = null;
        });

        // NEW: if valid, reflect into form + persist upstream once
        if (valid) {
          if (widget.formModel.destinationWallet != current) {
            widget.formModel.destinationWallet = current;
          }
          if (_lastPersisted != current) {
            _lastPersisted = current;
          }
        }
      });
    });

    _isValid = isSolanaAddress(_addressCtrl.text);

    _loadBurners();
  }

  Future<void> _loadBurners() async {
    setState(() => _loadingBurners = true);
    try {
      final items = await widget.fetchBurners();
      setState(() {
        _burners = items;
        // If form already had a burner destination, preselect it
        if (widget.formModel.destinationWallet != null) {
          final addr = widget.formModel.destinationWallet!;
          if (_burners.any((b) => b.publicKey == addr)) {
            _selectedBurnerAddress = addr;
            _mode = DestinationMode.burner;
            _tabCtrl.index = 1;
          }
        }
      });
    } finally {
      if (mounted) setState(() => _loadingBurners = false);
    }
  }

  void _handleNext() {
    if (_mode == DestinationMode.address) {
      if (!_isValid) {
        setState(() => _error = 'Invalid wallet address');
        return;
      }
      final addr = _addressCtrl.text.trim();
      widget.formModel.destinationWallet = addr;

      // belt & suspenders
      if (_lastPersisted != addr) {
        _lastPersisted = addr;
      }
    } else {
      if (_selectedBurnerAddress == null) return;
      final addr = _selectedBurnerAddress!;
      widget.formModel.destinationWallet = addr;

      if (_lastPersisted != addr) {
        _lastPersisted = addr;
      }
    }

    FocusScope.of(context).unfocus();
    widget.onNext();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _mode == DestinationMode.address ? _isValid : _selectedBurnerAddress != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text('Choose destination', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),

          const SizedBox(height: 20),

          // Tab header
          SegmentedTabs(
            controller: _tabCtrl,
            burnerCount: _burners.length, // if you have it; else 0
          ),

          const SizedBox(height: 26),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _AddressTab(
                  controller: _addressCtrl,
                  isValid: _isValid,
                  error: _error,
                  onPaste: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _addressCtrl.text = data!.text!.trim();
                    }
                  },
                ),
                _buildBurnerTab(context),
              ],
            ),
          ),

          // CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: widget.onBack, child: const Text('Back')),
              ElevatedButton(
                onPressed: canProceed ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* ------------------------- Burner tab ------------------------- */

  Widget _buildBurnerTab(BuildContext context) {
    if (_loadingBurners) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_burners.isEmpty) {
      return EmptyBurnerState(onCreate: _openCreateBurnerSheet);
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create burner'),
            onPressed: _openCreateBurnerSheet,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: _burners.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final b = _burners[i];
              final selected = b.publicKey == _selectedBurnerAddress;
              return BurnerTile(
                burner: b,
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick(); // NEW: subtle haptic
                  setState(() => _selectedBurnerAddress = b.publicKey);

                  // reflect + persist immediately
                  widget.formModel.destinationWallet = b.publicKey;
                  if (_lastPersisted != b.publicKey) {
                    _lastPersisted = b.publicKey;
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateBurnerSheet() async {
    final created = await showModalBottomSheet<BurnerWallet>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => CreateBurnerSheet(onCreate: widget.createBurner),
    );

    if (created != null) {
      // Refresh + select new burner
      await _loadBurners();
      setState(() => _selectedBurnerAddress = created.publicKey);
    }
  }
}

/* ----------------------- Address Tab (UI) ----------------------- */

class _AddressTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final String? error;
  final VoidCallback onPaste;

  const _AddressTab({
    required this.controller,
    required this.isValid,
    required this.error,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Send to a custom wallet address.',
          style: TextStyle(color: Colors.black.withOpacityCompat(0.8)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Destination address',
            // helperText: 'Base58 Solana address',
            // helperStyle: const TextStyle(fontSize: 12, color: Colors.black45),
            labelStyle: TextStyle(color: Colors.grey[700]),
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear',
                    onPressed: () {
                      controller.clear();
                    },
                  ),

                IconButton(icon: const Icon(Icons.paste), tooltip: 'Paste', onPressed: onPaste),
              ],
            ),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 2,
          style: const TextStyle(fontSize: 17, height: 1.4),
        ),
        if (controller.text.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isValid ? Icons.check : Icons.error,
                  color: isValid ? const Color(0xFF3D9E40) : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isValid ? 'Valid Solana address' : 'Invalid Solana address',
                  style: TextStyle(
                    color: isValid ? const Color(0xFF318034) : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}
