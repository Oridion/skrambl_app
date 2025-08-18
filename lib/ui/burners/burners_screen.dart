// lib/ui/burners/burners_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/local_database.dart';

class BurnersScreen extends StatelessWidget {
  const BurnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dao = context.read<BurnerDao>();

    return Scaffold(
      appBar: AppBar(title: const Text('Burners')),
      body: StreamBuilder<List<Burner>>(
        stream: dao.watchAllActive(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];

          if (items.isEmpty) {
            return _EmptyState(onCreate: () => _onCreate(context));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final b = items[i];
              return _BurnerTile(
                burner: b,
                onTap: () {
                  // TODO: open burner detail (pods from this burner, etc.)
                },
                onEditNote: () => _editNote(context, dao, b),
                onArchive: () async {
                  await dao.archive(b.pubkey, archived: true);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Burner archived')));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('New Burner'),
      ),
    );
  }

  void _onCreate(BuildContext context) {
    // TODO: Navigate to your “Create Burner” flow
    // e.g. Navigator.pushNamed(context, Routes.newBurner);
  }

  Future<void> _editNote(BuildContext context, BurnerDao dao, Burner b) async {
    final controller = TextEditingController(text: b.note ?? '');
    final note = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit note'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Add a note (optional)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (note != null) {
      await dao.setNote(b.pubkey, note.isEmpty ? null : note);
      // optional toast
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved')));
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department_rounded, size: 56, color: Colors.black54),
            const SizedBox(height: 10),
            const Text('No burners yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Create a burner address to send privately or compartmentalize funds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create burner'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BurnerTile extends StatelessWidget {
  final Burner burner;
  final VoidCallback onTap;
  final VoidCallback onEditNote;
  final VoidCallback onArchive;

  const _BurnerTile({
    required this.burner,
    required this.onTap,
    required this.onEditNote,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[];
    if ((burner.note ?? '').isNotEmpty) subtitle.add(burner.note!);
    subtitle.add('Index ${burner.derivationIndex}');
    subtitle.add('Txs ${burner.txCount}');
    if (burner.lastUsedAt != null) {
      subtitle.add('Used ${_relative(burner.lastUsedAt!)}');
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              const SizedBox(width: 12),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pubkey row
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _short(burner.pubkey),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (burner.used)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('USED', style: TextStyle(fontSize: 11, letterSpacing: 0.5)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.join(' • '),
                      style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'edit':
                      onEditNote();
                      break;
                    case 'archive':
                      onArchive();
                      break;
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit note')),
                  PopupMenuItem(value: 'archive', child: Text('Archive')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _short(String s, {int head = 6, int tail = 6}) {
    if (s.length <= head + tail + 1) return s;
    return '${s.substring(0, head)}…${s.substring(s.length - tail)}';
  }

  static String _relative(int unix) {
    final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(unix * 1000));
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
    // (you can swap in your RelativeTimeListen widget if you like)
  }
}
