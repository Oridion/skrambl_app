// lib/widgets/destination/create_burner_sheet.dart
import 'package:flutter/material.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';

class CreateBurnerSheet extends StatefulWidget {
  final Future<BurnerWallet> Function(String label) onCreate;
  const CreateBurnerSheet({super.key, required this.onCreate});

  @override
  State<CreateBurnerSheet> createState() => _CreateBurnerSheetState();
}

class _CreateBurnerSheetState extends State<CreateBurnerSheet> {
  final _labelCtrl = TextEditingController();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Create burner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Label / note (e.g., “Coffee”, “Ticket #123”)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final label = _labelCtrl.text.trim().isEmpty ? 'Burner' : _labelCtrl.text.trim();
    setState(() => _submitting = true);
    try {
      final burner = await widget.onCreate(label);
      if (!mounted) return;
      Navigator.pop(context, burner);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }
}
