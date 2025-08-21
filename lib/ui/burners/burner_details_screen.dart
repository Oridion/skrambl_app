import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/providers/selected_wallet_provider.dart';
import 'package:skrambl_app/ui/burners/empty_deliveries_screen.dart';
import 'package:skrambl_app/ui/burners/widgets/burner_header_card.dart';
import 'package:skrambl_app/ui/burners/widgets/burner_send_button.dart';
import 'package:skrambl_app/ui/burners/widgets/pod_row.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/solana.dart';

class BurnerDetailsScreen extends StatefulWidget {
  final String pubkey; // burner address
  final int burnerIndex; // optional

  const BurnerDetailsScreen({super.key, required this.pubkey, required this.burnerIndex});

  @override
  State<BurnerDetailsScreen> createState() => _BurnerDetailsScreenState();
}

class _BurnerDetailsScreenState extends State<BurnerDetailsScreen> {
  late final SelectedWalletProvider _selected; // cache the provider
  String? _prevPubkey;
  int? _prevBurnerIndex;
  bool _appliedSelection = false; // avoid double apply
  bool _restored = false;

  @override
  void initState() {
    super.initState();

    // Safe to read here; cache for later use (incl. dispose)
    _selected = context.read<SelectedWalletProvider>();
    _prevPubkey = _selected.pubkey;
    _prevBurnerIndex = _selected.burnerIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _appliedSelection) return;
      _selected.selectBurner(widget.pubkey, widget.burnerIndex);
      _appliedSelection = true;
    });
  }

  // Restore selected wallet to previous
  void _restorePreviousSelection() {
    if (_restored) return;
    _restored = true;

    if (_prevPubkey != null && _prevBurnerIndex != null) {
      _selected.selectBurner(_prevPubkey!, _prevBurnerIndex!);
    } else {
      _selected.selectPrimary();
    }
  }

  @override
  void dispose() {
    _restorePreviousSelection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use `read` so this widget itself doesn’t rebuild for DAO/provider changes.
    final burnerDao = context.read<BurnerDao>();
    final podDao = context.read<PodDao>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, bool? keepSelected) {
        if (!didPop) return; // pop was vetoed
        if (keepSelected == true) return; // a child explicitly asked to keep selection
        _restorePreviousSelection(); // otherwise, restore
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Transform.translate(
            offset: const Offset(-10, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, color: AppConstants.burnerColor),
                const SizedBox(width: 4),
                Text(shortenPubkey(widget.pubkey), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Copy address',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                // TODO: copyToClipboardWithToast(context, widget.pubkey)
              },
            ),
            IconButton(
              tooltip: 'View on explorer',
              icon: const Icon(Icons.open_in_new),
              onPressed: () => openAccountOnSolanaFM(context, widget.pubkey.toString()),
            ),
          ],
        ),
        body: StreamBuilder<Burner?>(
          stream: burnerDao.watchByPubkey(widget.pubkey),
          builder: (context, burnerSnap) {
            // Handle archived/removed burner while we’re on this screen
            if (burnerSnap.hasData && burnerSnap.data == null) {
              // Optionally inform user and leave
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('This burner was removed.')));
                Navigator.of(context).maybePop();
              });
            }

            final burner = burnerSnap.data; // can be null if just archived

            return Column(
              children: [
                const SizedBox(height: 8),
                HeaderCard(pubkey: widget.pubkey, burner: burner),
                const SizedBox(height: 12),

                // SEND BUTTON (auto-disables on no funds inside)
                BurnerSendButton(burnerPubkey: widget.pubkey),
                const SizedBox(height: 16),

                // Deliveries
                Expanded(
                  child: StreamBuilder<List<Pod>>(
                    stream: podDao.watchByAddress(widget.pubkey),
                    builder: (context, podsSnap) {
                      if (podsSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final pods = podsSnap.data ?? const [];
                      if (pods.isEmpty) {
                        return const EmptyDeliveries();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: pods.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => PodRow(pod: pods[i], burnerPubkey: widget.pubkey),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
