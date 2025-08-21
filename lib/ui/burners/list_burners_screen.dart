// lib/ui/burners/burners_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/ui/burners/burner_details_screen.dart';
import 'package:skrambl_app/ui/burners/empty_burner_state.dart';
import 'package:skrambl_app/ui/burners/widgets/list_burner_tile.dart';
import 'package:skrambl_app/ui/shared/burner_flows.dart';

class BurnersScreen extends StatelessWidget {
  const BurnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<BurnerDao>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Burners'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Create burner',
            icon: const Icon(Icons.add),
            onPressed: () => openCreateBurnerSheet(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Burner>>(
        stream: dao.watchAllActive(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return EmptyBurnerState(onCreate: () => openCreateBurnerSheet(context));
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final b = items[i];
                return ListBurnerTile(
                  burner: b,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BurnerDetailsScreen(pubkey: b.pubkey, burnerIndex: b.derivationIndex),
                      ),
                    );
                  },
                  onCopy: () async {
                    await Clipboard.setData(ClipboardData(text: b.pubkey));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Address copied')));
                  },
                  onEditNote: () => editNote(context, dao, b),
                  onArchive: () async {
                    await dao.archive(b.pubkey, archived: true);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Burner archived')));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
