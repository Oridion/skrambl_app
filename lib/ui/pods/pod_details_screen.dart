import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/ui/pods/helper/pod_timeline_builder.dart';
import 'package:skrambl_app/ui/pods/widgets/actions_bar.dart';
import 'package:skrambl_app/ui/pods/widgets/details_table.dart';
import 'package:skrambl_app/ui/pods/widgets/pod_header_card.dart';
import 'package:skrambl_app/ui/pods/widgets/section_wrapper.dart';
import 'package:skrambl_app/ui/pods/widgets/vertical_timeline.dart';
import 'package:skrambl_app/ui/shared/pod_status_colors.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/launcher.dart';

class PodDetailsScreen extends StatelessWidget {
  final String localId; // pods.id from Drift table (string UUID or similar)
  const PodDetailsScreen({super.key, required this.localId});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Details'), titleSpacing: 24),
      body: StreamBuilder<Pod?>(
        stream: dao.watchById(localId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pod = snap.data;
          if (pod == null) {
            return const Center(child: Text('Delivery not found'));
          }

          final status = PodStatus.values[pod.status];
          final chipColor = statusColor(status);

          final draftedAt = dateTimeOrNull(pod.draftedAt);
          final submittedAt = dateTimeOrNull(pod.submittedAt);
          final finalizedAt = dateTimeOrNull(pod.finalizedAt);

          final timeline = buildTimeline(
            draftedAt: draftedAt,
            submittedAt: submittedAt,
            finalizedAt: finalizedAt,
            status: status,
            pod: pod,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              // ===== HEADER CARD =====
              PodHeaderCard(
                status: status,
                chipColor: chipColor,
                draftedAt: dateTimeOrNull(pod.draftedAt * 1000),
                lamports: pod.lamports,
                pod: pod,
              ),
              const SizedBox(height: 16),

              // ===== TIMELINE =====
              VerticalTimeline(items: timeline, pod: pod),
              // SectionWrapper(
              //   label: 'TIMELINE',
              //   child: VerticalTimeline(items: timeline, pod: pod),
              // ),

              // ===== DETAILS =====
              SectionWrapper(
                label: 'DETAILS',
                child: PodDetailsTable(
                  rows: [
                    PodDetailRow('TYPE', modeLabel(pod.mode)),
                    if (pod.mode != 5) PodDetailRow('DELAY', delayLabel(pod.delaySeconds)),
                    // PodDetailRow('CREATOR', shortenPubkey(pod.creator)),
                    // PodDetailRow('DESTINATION', shortenPubkey(pod.destination), copyable: true),
                    if (pod.podPda != null) PodDetailRow('PDA', pod.podPda!, copyable: true),
                  ],
                ),
              ),

              // ===== ACTIONS =====
              PodActionsBar(pda: pod.podPda, signature: pod.launchSig),
            ],
          );
        },
      ),
    );
  }
}
