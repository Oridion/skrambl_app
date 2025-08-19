// lib/widgets/destination/create_burner_sheet.dart
import 'package:flutter/material.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';

class CreateBurnerSheet extends StatefulWidget {
  final Future<BurnerWallet> Function(String label) onCreate;
  const CreateBurnerSheet({super.key, required this.onCreate});

  @override
  State<CreateBurnerSheet> createState() => _CreateBurnerSheetState();
}

class _CreateBurnerSheetState extends State<CreateBurnerSheet> with TickerProviderStateMixin {
  final _labelCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();

    final label = _labelCtrl.text.trim().isEmpty ? 'Burner' : _labelCtrl.text.trim();

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final burner = await widget.onCreate(label);
      if (!mounted) return;
      Navigator.pop(context, burner); // success -> close & return value
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString(); // show inline error; keep sheet open
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canSubmit = !_submitting && (_labelCtrl.text.trim().length <= 60); // simple guard

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
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
              const SizedBox(height: 20),
              TextField(
                controller: _labelCtrl,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                maxLength: 60,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Optional note (e.g., “Coffee”, “Ticket #123”)',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                  setState(() {}); // refresh button enabled state
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                child: _error == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12.5)),
                      ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create Burner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
