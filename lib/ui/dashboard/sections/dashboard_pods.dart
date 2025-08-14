// lib/ui/dashboard/widgets/pods_sliver.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/shared/relative_time.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/logger.dart';

class PodsSliver extends StatelessWidget {
  const PodsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();

    return StreamBuilder<List<Pod>>(
      stream: dao.watchRecent(),
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
                    Icon(Icons.view_timeline, size: 56, color: const Color.fromARGB(255, 192, 192, 192)),
                    const SizedBox(height: 12),
                    const Text(
                      'No deliveries yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Send your first SKRAMBLed delivery. Your delivers will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            (context, i) => _PodCard(pod: pods[i]),
            childCount: pods.length,
          ),
        );
      },
    );
  }
}

class _PodCard extends StatelessWidget {
  final Pod pod;
  const _PodCard({required this.pod});

  @override
  Widget build(BuildContext context) {
    skrLogger.i(pod);

    final status = PodStatus.values[pod.status];
    Color chip = switch (status) {
      PodStatus.drafting => Colors.grey,
      PodStatus.launching => Colors.blueGrey,
      PodStatus.submitted => Colors.blue,
      PodStatus.scrambling => Colors.deepPurple,
      PodStatus.delivering => Colors.orange,
      PodStatus.finalized => Colors.green,
      PodStatus.failed => Colors.red,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black,
          child: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
        ),
        title: RelativeTimeListen(
          time: DateTime.fromMillisecondsSinceEpoch(pod.draftedAt * 1000), // convert from seconds
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          '${pod.lamports / 1000000000} to ${shortenPubkey(pod.destination)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: chip.withOpacityCompat(.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: chip.withOpacityCompat(.35)),
          ),
          child: Text(
            status.name.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: chip),
          ),
        ),
        onTap: () {
          // TODO: navigate to pod details using localId = pod.id
        },
      ),
    );
  }
}
