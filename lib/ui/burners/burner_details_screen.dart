// lib/ui/burners/burner_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/providers/burner_balances_provider.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/ui/burners/widgets/burner_send_button.dart';
import 'package:skrambl_app/ui/shared/pod_status_colors.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class BurnerDetailsScreen extends StatelessWidget {
  final String pubkey; // burner address
  const BurnerDetailsScreen({super.key, required this.pubkey});

  @override
  Widget build(BuildContext context) {
    final burnerDao = context.read<BurnerDao>();
    final podDao = context.read<PodDao>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Transform.translate(
          offset: const Offset(-10, 0), // move 12px to the left
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department, color: AppConstants.burnerColor),
              SizedBox(width: 4),
              Text(shortenPubkey(pubkey), style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Copy address',
            icon: const Icon(Icons.copy_rounded),
            //onPressed: () => copyToClipboardWithToast(context, pubkey),
            onPressed: () => {},
          ),
          IconButton(
            tooltip: 'View on explorer',
            icon: const Icon(Icons.open_in_new),
            //onPressed: () => openSolanaExplorerAccount(pubkey),
            onPressed: () => {},
          ),
        ],
      ),
      body: StreamBuilder<Burner?>(
        stream: burnerDao.watchByPubkey(pubkey),
        builder: (context, burnerSnap) {
          final burner = burnerSnap.data; // can be null if archived/removed
          return Column(
            children: [
              const SizedBox(height: 8),
              _HeaderCard(pubkey: pubkey, burner: burner),
              const SizedBox(height: 12),

              // SEND BUTTON
              BurnerSendButton(burnerPubkey: pubkey),
              const SizedBox(height: 16),

              // Deliveries
              Expanded(
                child: StreamBuilder<List<Pod>>(
                  stream: podDao.watchByAddress(pubkey),
                  builder: (context, podsSnap) {
                    if (podsSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final pods = podsSnap.data ?? const [];
                    if (pods.isEmpty) {
                      return const _EmptyDeliveries();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: pods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _PodRow(pod: pods[i], burnerPubkey: pubkey),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String pubkey;
  final Burner? burner;
  const _HeaderCard({required this.pubkey, required this.burner});

  @override
  Widget build(BuildContext context) {
    final balances = context.watch<BurnerBalancesProvider>();
    final price = context.watch<PriceProvider>().solUsd;

    final lamports = balances.lamportsFor(pubkey);
    final sol = lamports / 1e9;
    final usd = sol * price;

    final note = burner?.note;
    final used = burner?.used == true;
    final idx = burner?.derivationIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              // Left: address + note + tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address
                    Text(
                      shortenPubkey(pubkey, length: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 3),

                    // Optional note
                    if ((note ?? '').isNotEmpty)
                      Text(
                        note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black.withOpacityCompat(0.7)),
                      ),

                    const SizedBox(height: 10),

                    // Chips: Used / Index
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(
                          used ? 'USED' : 'UNUSED',
                          used ? Colors.red.shade50 : const Color(0xFFF2F2F2),
                          used ? Colors.red.shade700 : Colors.black87,
                        ),
                        if (idx != null) _chip('IDX: $idx', const Color(0xFFF2F2F2), Colors.black87),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right: balances
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatSol(sol)} SOL',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    usd <= 0 ? '0 USD' : '\$${usd.toStringAsFixed(2)} USD',
                    style: TextStyle(color: Colors.black.withOpacityCompat(0.65), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _EmptyDeliveries extends StatelessWidget {
  const _EmptyDeliveries();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department_outlined, size: 48, color: Colors.black54),
            const SizedBox(height: 10),
            const Text('No deliveries yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              'Transactions sent from or to this burner will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withOpacityCompat(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodRow extends StatelessWidget {
  final Pod pod;
  final String burnerPubkey;
  const _PodRow({required this.pod, required this.burnerPubkey});

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
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => PodDetailsScreen(localId: pod.id)));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              // left color dot

              // direction icon
              Icon(isSender ? Icons.north_east : Icons.south_west, size: 16, color: color),

              const SizedBox(width: 12),

              // center text
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

              // right chevron
              const Icon(Icons.chevron_right_rounded, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
