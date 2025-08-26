import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/ui/pods/pod_details_screen.dart';
import 'package:skrambl_app/ui/shared/pod_card.dart';

class PodsSliver extends StatelessWidget {
  const PodsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();

    return StreamBuilder<List<Pod>>(
      stream: dao.watchRecent(), // ideally LIMIT + proper index in SQL
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final pods = snap.data ?? const <Pod>[];
        if (pods.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 220, 220, 220),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppConstants.skramblIcon, size: 56, color: const Color.fromARGB(255, 192, 192, 192)),
                    const SizedBox(height: 12),
                    const Text(
                      'No deliveries yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Send your first SKRAMBLed delivery. Your deliveries will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final pod = pods[i];
              return PodCard(
                key: ValueKey(pod.id), // stable identity for diffing/recycling
                pod: pod,
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => PodDetailsScreen(localId: pod.id)));
                },
              );
            },
            childCount: pods.length,
            addAutomaticKeepAlives: false, // reduce memory unless you rely on it
            addRepaintBoundaries: true, // keep for perf
            addSemanticIndexes: false, // optional
            // helps the sliver keep items stable when list changes
            findChildIndexCallback: (Key key) {
              if (key is ValueKey<String>) {
                final id = key.value;
                final index = pods.indexWhere((p) => p.id == id);
                return index == -1 ? null : index;
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
