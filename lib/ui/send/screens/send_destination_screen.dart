import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/ui/burners/widgets/burner_tile.dart';
import 'package:skrambl_app/ui/burners/create_burner_sheet.dart';
import 'package:skrambl_app/ui/burners/empty_burner_state.dart';
import 'package:skrambl_app/models/send_form_model.dart';
import 'package:skrambl_app/ui/send/widgets/destination_tab_header.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/launcher.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

enum DestinationMode { address, burner }

class SendDestinationScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final SendFormModel formModel;
  final Future<List<BurnerWallet>> Function() fetchBurners;
  final Future<BurnerWallet?> Function({String? note, required AuthToken token}) createBurner;

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
  bool _isNextLoading = false;

  // Burner mode
  List<BurnerWallet> _burners = [];
  String? _selectedBurnerAddress;

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
        _error = null; // clear any prior error when switching modes
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
      });
    });

    _isValid = isSolanaAddress(_addressCtrl.text);

    _loadBurners();
  }

  Future<void> _loadBurners() async {
    final items = await widget.fetchBurners();
    setState(() {
      _burners = items;
      // If form already had a burner destination, preselect it
      if (widget.formModel.destinationWallet != null) {
        final addr = widget.formModel.destinationWallet!;
        if (_burners.any((b) => b.publicKey == addr)) {
          _selectedBurnerAddress = addr;
          widget.formModel.isDestinationBurner = true;
          _mode = DestinationMode.burner;
          _tabCtrl.index = 1;
        }
      }
    });
  }

  void _handleNext() {
    if (_mode == DestinationMode.address) {
      final addr = _addressCtrl.text.trim();
      if (!_isValid) {
        setState(() => _error = 'Invalid wallet address');
        return;
      }
      widget.formModel.destinationWallet = addr;
      widget.formModel.isDestinationBurner = false;
    } else {
      // Burner mode
      if (_selectedBurnerAddress == null) {
        // Optional: give user feedback
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Select a burner wallet to continue')));
        return;
      }
      widget.formModel.destinationWallet = _selectedBurnerAddress!;
      widget.formModel.isDestinationBurner = true;
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
                  onClear: () {
                    widget.formModel.destinationWallet = null;
                    widget.formModel.isDestinationBurner = false;
                  },
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
                onPressed: (canProceed && !_isNextLoading)
                    ? () async {
                        FocusScope.of(context).unfocus();
                        setState(() => _isNextLoading = true);

                        await Future.delayed(const Duration(milliseconds: 500));
                        if (!mounted) return;

                        setState(() => _isNextLoading = false);
                        _handleNext();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
        ],
      ),
    );
  }

  /* ------------------------- Burner tab ------------------------- */

  Widget _buildBurnerTab(BuildContext context) {
    final dao = context.read<BurnerDao>();

    return StreamBuilder<List<Burner>>(
      stream: dao.watchAllActive(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final burners = snap.data ?? const [];

        if (burners.isEmpty) {
          return EmptyBurnerState(onCreate: _openCreateBurnerSheet);
        }

        // keep selection in sync if the list changed
        if (_selectedBurnerAddress != null && !burners.any((b) => b.pubkey == _selectedBurnerAddress)) {
          _selectedBurnerAddress = null;
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
                itemCount: burners.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final b = burners[i];
                  final selected = b.pubkey == _selectedBurnerAddress;
                  return BurnerTile(
                    burner: BurnerWallet(
                      index: b.derivationIndex,
                      publicKey: b.pubkey,
                      note: b.note,
                      used: b.used,
                    ),
                    selected: selected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (_selectedBurnerAddress == b.pubkey) {
                          _selectedBurnerAddress = null; // deselect if tapped again
                        } else {
                          _selectedBurnerAddress = b.pubkey;
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCreateBurnerSheet() async {
    final created = await showModalBottomSheet<BurnerWallet>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacityCompat(0.35),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(6))),
      builder: (sheetCtx) => CreateBurnerSheet(
        onCreate: (label) async {
          final token = await SeedVaultService.getValidToken(sheetCtx);
          if (token == null) {
            throw Exception('Seed Vault permission denied');
          }

          final burner = await widget.createBurner(note: label, token: token);
          if (burner == null) throw Exception('Failed to create burner');
          return burner;
        },
      ),
    );

    if (created == null) return;
    await _loadBurners();
    setState(() => _selectedBurnerAddress = created.publicKey);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Burner created')));
  }
}

/* ----------------------- Address Tab (UI) ----------------------- */

class _AddressTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final String? error;
  final VoidCallback onPaste;
  final VoidCallback onClear;

  const _AddressTab({
    required this.controller,
    required this.isValid,
    required this.error,
    required this.onPaste,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Text(
        //   'Enter a custom destination address.',
        //   style: TextStyle(color: Colors.black.withOpacityCompat(0.8)),
        // ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter the destination address',
            labelStyle: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 73, 73, 73)),
            border: const OutlineInputBorder(
              gapPadding: 5,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear',
                    onPressed: () {
                      controller.clear();
                      onClear();
                    },
                  ),
                IconButton(icon: const Icon(Icons.paste), tooltip: 'Paste', onPressed: onPaste),
              ],
            ),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 2,
          style: const TextStyle(fontSize: 17, height: 1.5),
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
