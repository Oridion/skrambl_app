import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/burner_dao.dart';
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
import 'package:skrambl_app/utils/logger.dart';

class PodDetailsScreen extends StatelessWidget {
  final String localId; // pods.id from Drift table (string UUID or similar)
  const PodDetailsScreen({super.key, required this.localId});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<PodDao>();
    final burnerDao = context.read<BurnerDao>();

    Future<void> confirmAndDeleteDraft(Pod pod) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          backgroundColor: Colors.white,
          title: const Text('Delete draft?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: const Text(
            'This will permanently remove the draft delivery.',
            style: TextStyle(fontSize: 14),
          ),

          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.burnerColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (ok != true) return;

      try {
        await dao.deleteById(localId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft deleted')));
        Navigator.of(context).maybePop();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
        titleSpacing: 24,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),

        actions: [
          StreamBuilder<Pod?>(
            stream: dao.watchById(localId),
            builder: (context, snap) {
              final pod = snap.data;
              if (pod == null) return const SizedBox.shrink();

              // final status = PodStatus.values[pod.status];
              // final isDraft = status == PodStatus.drafting;
              // if (!isDraft) return const SizedBox.shrink();

              return IconButton(
                tooltip: 'Delete draft',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => confirmAndDeleteDraft(pod),
              );
            },
          ),
        ],
      ),
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

          skrLogger.i(pod);

          final addrs = {pod.creator, pod.destination};
          return FutureBuilder<Set<String>>(
            future: burnerDao.findBurnersIn(addrs),
            builder: (context, bSnap) {
              final burners = bSnap.data ?? const {};
              final isSenderBurner = burners.contains(pod.creator);
              final isDestinationBurner = burners.contains(pod.destination);
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
                    isSenderBurner: isSenderBurner,
                    isDestinationBurner: isDestinationBurner,
                  ),
                  const SizedBox(height: 12),

                  // ===== TIMELINE =====
                  VerticalTimeline(pod: pod),

                  // ===== DETAILS =====
                  SectionWrapper(
                    label: 'DETAILS',
                    child: PodDetailsTable(
                      rows: [
                        PodDetailRow('TYPE', modeLabel(pod.mode)),

                        if (pod.submittedAt != null)
                          PodDetailRow('SUBMITTED', formatEpochSecLocal(pod.submittedAt!)),

                        if (pod.mode != 5) PodDetailRow('DELAY', delayLabel(pod.delaySeconds)),
                        // PodDetailRow('CREATOR', shortenPubkey(pod.creator)),
                        // PodDetailRow('DESTINATION', shortenPubkey(pod.destination), copyable: true),
                        if (pod.podPda != null)
                          PodDetailRow(
                            'PDA',
                            shortenPubkey(pod.podPda!, length: 8),
                            copyText: pod.podPda!,
                            copyable: true,
                          ),

                        if (pod.lastSig != null)
                          PodDetailRow(
                            'TX',
                            shortenPubkey(pod.launchSig.toString(), length: 10),
                            copyText: pod.launchSig.toString(),
                            copyable: true,
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
