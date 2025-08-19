// lib/ui/burners/burner_flows.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/burner_repository.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';
import 'package:skrambl_app/ui/burners/create_burner_sheet.dart';

String _short(String s, {int head = 6, int tail = 6}) =>
    s.length <= head + tail + 1 ? s : '${s.substring(0, head)}…${s.substring(s.length - tail)}';

Future<void> openCreateBurnerSheet(BuildContext context) async {
  final repo = context.read<BurnerRepository>();

  final created = await showModalBottomSheet<BurnerWallet>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => CreateBurnerSheet(
      onCreate: (label) async {
        // Fetch a fresh token right before the sensitive op
        final token = await SeedVaultService.getValidToken(ctx);
        if (token == null) {
          throw Exception('Seed Vault authorization denied');
        }
        final burner = await repo.createBurner(token: token, note: label);
        if (burner == null) {
          throw Exception('Burner creation failed');
        }
        return burner;
      },
    ),
  );

  if (created != null && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Burner created: ${_short(created.publicKey)}')));
  }
}

Future<void> editNote(BuildContext context, BurnerDao dao, Burner b) async {
  final controller = TextEditingController(text: b.note ?? '');
  final note = await showDialog<String?>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // square-ish dialog
        side: const BorderSide(color: Colors.black, width: 2), // black border
      ),
      title: const Text('Edit note', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: controller,
        maxLines: 2,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Add a note (optional)',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // black outline
          ),
          contentPadding: EdgeInsets.all(12),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // black save button
            foregroundColor: Colors.white, // white text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6), // matches dialog
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (note != null) {
    await dao.setNote(b.pubkey, note.isEmpty ? null : note);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved')));
    }
  }
}
