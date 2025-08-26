import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/pods/all_pods_screen.dart';

class SectionTitleSliver extends StatelessWidget {
  const SectionTitleSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(26, 7, 26, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            const Expanded(
              child: Text('LATEST DELIVERIES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllPods())),
              child: const Text('View more', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            ),
          ],
        ),
      ),
    );
  }
}
