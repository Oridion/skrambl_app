// lib/ui/pods/pods_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/pods/pod_details_screen.dart';
import 'package:skrambl_app/ui/shared/filter_chip.dart';
import 'package:skrambl_app/ui/shared/pod_card.dart';

enum PodsFilter { all, active, finalized, failed }

class AllPods extends StatefulWidget {
  const AllPods({super.key});

  @override
  State<AllPods> createState() => _AllPodsState();
}

class _AllPodsState extends State<AllPods> {
  PodsFilter _filter = PodsFilter.all;

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Deliveries'),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),

        titleSpacing: 24, // matches horizontal padding
      ),
      body: StreamBuilder<List<Pod>>(
        stream: dao.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pods = snapshot.data ?? const <Pod>[];
          if (pods.isEmpty) return const _EmptyPodsAllPage();

          // --- counts for header ---
          int activeCount = pods.where((p) {
            final s = PodStatus.values[p.status];
            return s == PodStatus.launching ||
                s == PodStatus.submitted ||
                s == PodStatus.scrambling ||
                s == PodStatus.delivering;
          }).length;
          int finalizedCount = pods.where((p) => PodStatus.values[p.status] == PodStatus.finalized).length;
          int failedCount = pods.where((p) => PodStatus.values[p.status] == PodStatus.failed).length;

          // --- filtering ---
          final filtered = pods.where((p) {
            final s = PodStatus.values[p.status];
            switch (_filter) {
              case PodsFilter.all:
                return true;
              case PodsFilter.active:
                return s == PodStatus.launching ||
                    s == PodStatus.submitted ||
                    s == PodStatus.scrambling ||
                    s == PodStatus.delivering;
              case PodsFilter.finalized:
                return s == PodStatus.finalized;
              case PodsFilter.failed:
                return s == PodStatus.failed;
            }
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PodsHeader(
                  total: pods.length,
                  active: activeCount,
                  finalized: finalizedCount,
                  failed: failedCount,
                  selected: _filter,
                  onFilterChanged: (f) => setState(() => _filter = f),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
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
}

class PodsHeader extends StatelessWidget {
  final int total;
  final int active;
  final int finalized;
  final int failed;
  final PodsFilter selected;
  final ValueChanged<PodsFilter> onFilterChanged;

  const PodsHeader({
    super.key,
    required this.total,
    required this.active,
    required this.finalized,
    required this.failed,
    required this.selected,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 0,
            children: [
              // Inside Wrap():
              FilterChipSmall(
                label: 'All • $total',
                selected: selected == PodsFilter.all,
                onSelected: () => onFilterChanged(PodsFilter.all),
              ),
              FilterChipSmall(
                label: 'Active • $active',
                selected: selected == PodsFilter.active,
                onSelected: () => onFilterChanged(PodsFilter.active),
              ),
              FilterChipSmall(
                label: 'Completed • $finalized',
                selected: selected == PodsFilter.finalized,
                onSelected: () => onFilterChanged(PodsFilter.finalized),
              ),
              FilterChipSmall(
                label: 'Failed • $failed',
                selected: selected == PodsFilter.failed,
                onSelected: () => onFilterChanged(PodsFilter.failed),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //   Widget _chip(BuildContext context, {required String label, required PodsFilter value}) {
  //     final isSelected = selected == value;
  //     return ChoiceChip(
  //       label: Text(label),
  //       selected: isSelected,
  //       onSelected: (ok) {
  //         if (ok) onFilterChanged(value);
  //       },
  //       showCheckmark: false,
  //       shape: StadiumBorder(
  //         side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300),
  //       ),
  //     );
  //   }
}

class _EmptyPodsAllPage extends StatelessWidget {
  const _EmptyPodsAllPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 220, 220, 220),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 22),
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
