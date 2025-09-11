import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/ui/pods/pod_details_screen.dart';
import 'package:skrambl_app/ui/shared/chips.dart';
import 'package:skrambl_app/ui/shared/pod_card.dart';

/// New filter set: ALL / SKRAMBLED / STANDARD
// ...imports unchanged...

enum PodsFilter { all, skrambled, standard }

class AllPods extends StatefulWidget {
  const AllPods({super.key});

  @override
  State<AllPods> createState() => _AllPodsState();
}

class _AllPodsState extends State<AllPods> {
  PodsFilter _filter = PodsFilter.all;

  // Keeps the same Stream; no flash.
  final _scrollCtrl = ScrollController();
  int _refreshNonce = 0; // forces a lightweight rebuild without changing the stream

  Future<void> _scrollToTop() async {
    if (!_scrollCtrl.hasClients) return;
    await _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  Future<void> _onReselect() async {
    // Optional: haptic click for UX feedback
    // HapticFeedback.selectionClick();

    // Gentle "refresh": rebuild filtered list, keep the same stream → no loading flash.
    if (mounted) setState(() => _refreshNonce++);

    // Scroll to top so refreshed content is immediately visible.
    await _scrollToTop();

    // If you have a DAO refresh/sync method, you can call it here.
    // final dao = context.read<PodDao>();
    // await dao.refreshAll(); // (Only if it exists; otherwise omit)
  }

  void _onFilterTap(PodsFilter next) {
    if (next == _filter) {
      _onReselect();
    } else {
      setState(() => _filter = next);
      _scrollToTop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text('All Deliveries'),
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        titleSpacing: 0,
      ),
      body: StreamBuilder<List<Pod>>(
        stream: dao.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pods = snapshot.data ?? const <Pod>[];
          if (pods.isEmpty) return const _EmptyPodsAllPage();

          final skrambledCount = pods.where(isSkrambledPod).length;
          final standardCount = pods.length - skrambledCount;

          // _refreshNonce is referenced so a reselect triggers a rebuild without changing streams
          // (no-op use to silence analyzer about unused variable)
          // ignore: unused_local_variable
          final _ = _refreshNonce;

          final filtered = pods.where((p) {
            switch (_filter) {
              case PodsFilter.all:
                return true;
              case PodsFilter.skrambled:
                return isSkrambledPod(p);
              case PodsFilter.standard:
                return !isSkrambledPod(p);
            }
          }).toList();

          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              const SliverPadding(padding: EdgeInsets.only(bottom: 8)),
              SliverToBoxAdapter(
                child: PodsHeader(
                  total: pods.length,
                  skrambled: skrambledCount,
                  standard: standardCount,
                  selected: _filter,
                  onFilterChanged: _onFilterTap, // <-- handles both change and reselect
                  onReselect: _onReselect, // <-- optional explicit reselect hook (used internally)
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                sliver: SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => PodCard(
                    pod: filtered[i],
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => PodDetailsScreen(localId: filtered[i].id)));
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool isSkrambledPod(Pod p) => p.mode == 1 || p.mode == 3;
}

class PodsHeader extends StatelessWidget {
  final int total;
  final int skrambled;
  final int standard;
  final PodsFilter selected;
  final ValueChanged<PodsFilter> onFilterChanged;
  final VoidCallback? onReselect;

  const PodsHeader({
    super.key,
    required this.total,
    required this.skrambled,
    required this.standard,
    required this.selected,
    required this.onFilterChanged,
    this.onReselect,
  });

  void _handleTap(PodsFilter target) {
    if (target == selected) {
      onReselect?.call();
    } else {
      onFilterChanged(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 0,
            children: [
              FilterChipSmall(
                label: 'ALL • $total',
                selected: selected == PodsFilter.all,
                onSelected: () => _handleTap(PodsFilter.all),
              ),
              FilterChipSmall(
                label: 'SKRAMBLED • $skrambled',
                selected: selected == PodsFilter.skrambled,
                onSelected: () => _handleTap(PodsFilter.skrambled),
              ),
              FilterChipSmall(
                label: 'STANDARD • $standard',
                selected: selected == PodsFilter.standard,
                onSelected: () => _handleTap(PodsFilter.standard),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// _EmptyPodsAllPage unchanged...

class _EmptyPodsAllPage extends StatelessWidget {
  const _EmptyPodsAllPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 22),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppConstants.skramblIcon, size: 56, color: Color.fromARGB(255, 192, 192, 192)),
            SizedBox(height: 12),
            Text('No deliveries yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 7),
            Text(
              'Send your first SKRAMBLed delivery. Your deliveries will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
