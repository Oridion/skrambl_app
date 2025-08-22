import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/local_database.dart';

class DebugBurnerPanel extends StatelessWidget {
  final String pubkey;
  const DebugBurnerPanel({super.key, required this.pubkey});

  Map<String, dynamic> _burnerToMap(Burner b) => {
    'pubkey': b.pubkey,
    'note': b.note,
    'derivationIndex': b.derivationIndex,
    'used': b.used,
    'txCount': b.txCount,
    'archived': b.archived,
    'createdAt': b.createdAt,
    'lastUsedAt': b.lastUsedAt,
    'lastSeenAt': b.lastSeenAt,
  };

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final dao = context.read<BurnerDao>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: StreamBuilder<Burner?>(
        stream: dao.watchByPubkey(pubkey),
        builder: (context, snap) {
          final burner = snap.data;
          final body = burner == null
              ? const Text('No row for this pubkey (null).')
              : SelectableText(
                  const JsonEncoder.withIndent('  ').convert(_burnerToMap(burner)),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
                );

          return Material(
            color: const Color(0xFFFFF3F3),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DEBUG • Burner row',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  body,
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (burner != null) {
                            await dao.markUsed(pubkey: burner.pubkey);
                          }
                        },
                        child: const Text('Mark used(true)'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          if (burner != null) {
                            await Clipboard.setData(
                              ClipboardData(
                                text: const JsonEncoder.withIndent('  ').convert(_burnerToMap(burner)),
                              ),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(const SnackBar(content: Text('Copied burner JSON')));
                            }
                          }
                        },
                        child: const Text('Copy JSON'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
