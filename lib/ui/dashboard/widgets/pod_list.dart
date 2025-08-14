import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/ui/pods/all_pods_screen.dart';
import 'package:skrambl_app/utils/formatters.dart';

class PodListSection extends StatelessWidget {
  const PodListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('LATEST DELIVERIES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllPods()));
              },
              child: const Text('View more', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        StreamBuilder(
          stream: dao.watchRecent(limit: 5),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
              );
            }
            final pods = snapshot.data!;
            if (pods.isEmpty) {
              return Container(
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
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pods.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = pods[i];
                final title = 'Pod #${p.podId} → ${p.destination}';
                final subtitle = 'Status: ${p.status} · ${formatTimeAgo(p.draftedAt * 1000)}';
                return ListTile(
                  dense: true,
                  title: Text(title),
                  subtitle: Text(subtitle),
                  onTap: () {
                    // TODO: push a PodDetail screen if you have one
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
