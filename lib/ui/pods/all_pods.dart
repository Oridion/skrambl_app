// lib/ui/pods/pods_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class AllPods extends StatelessWidget {
  const AllPods({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pods')),
      body: StreamBuilder<List<Pod>>(
        stream: dao.watchAll(), // already ordered by createdAt desc in your DAO
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pods = snapshot.data ?? const <Pod>[];

          if (pods.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.all_inbox, size: 48, color: Colors.grey[500]),
                    const SizedBox(height: 12),
                    const Text('No pods yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Launch your first SKRAMBLed delivery!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: pods.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = pods[i];
              return _PodTile(pod: p);
            },
          );
        },
      ),
    );
  }
}

class _PodTile extends StatelessWidget {
  final Pod pod;
  const _PodTile({required this.pod});

  @override
  Widget build(BuildContext context) {
    final status = PodStatus.values[pod.status];
    Color chipColor;
    switch (status) {
      case PodStatus.drafting:
        chipColor = Colors.grey;
        break;
      case PodStatus.launching:
        chipColor = Colors.blueGrey;
        break;
      case PodStatus.submitted:
        chipColor = Colors.blue;
        break;
      case PodStatus.scrambling:
        chipColor = Colors.deepPurple;
        break;
      case PodStatus.delivering:
        chipColor = Colors.orange;
        break;
      case PodStatus.finalized:
        chipColor = Colors.green;
        break;
      case PodStatus.failed:
        chipColor = Colors.red;
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black,
          child: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
        ),
        title: Text(
          pod.destination,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Lamports: ${pod.lamports} • Created: ${formatFullDateTime(pod.draftedAt * 1000)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor.withOpacityCompat(.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: chipColor.withOpacityCompat(.35)),
          ),
          child: Text(
            status.name.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: chipColor),
          ),
        ),
        onTap: () {
          // TODO: navigate to a pod detail page with localId = pod.id
        },
      ),
    );
  }
}
