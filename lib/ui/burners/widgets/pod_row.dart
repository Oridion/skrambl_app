import 'package:flutter/material.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/ui/shared/pod_status_colors.dart'; // statusColor()
import 'package:skrambl_app/utils/formatters.dart'; // formatSol()

class PodRow extends StatelessWidget {
  final Pod pod;

  /// The burner address used to determine direction (sent/received).
  final String burnerPubkey;

  /// Optional tap action (e.g., open details).
  final VoidCallback? onTap;

  const PodRow({super.key, required this.pod, required this.burnerPubkey, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSender = pod.creator == burnerPubkey;
    final isReceiver = pod.destination == burnerPubkey;

    final status = PodStatus.values[pod.status];
    final color = statusColor(status);

    final amountSol = pod.lamports / 1e9;
    final direction = isSender ? 'Sent' : (isReceiver ? 'Received' : 'Delivery');
    final otherParty = isSender ? pod.destination : pod.creator;
    final details = '${isSender ? "To" : "From"} ${shortenPubkey(otherParty)}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              Icon(isSender ? Icons.north_east : Icons.south_west, size: 16, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$direction • ${formatSol(amountSol)} SOL',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(details, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
                  ],
                ),
              ),
              //const Icon(Icons.chevron_right_rounded, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
