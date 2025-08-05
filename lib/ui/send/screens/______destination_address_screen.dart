import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/logger.dart';
import '../send_form_model.dart';

class DestinationAddressScreen extends StatefulWidget {
  final SendFormModel formModel;
  final VoidCallback onNext;

  const DestinationAddressScreen({
    super.key,
    required this.formModel,
    required this.onNext,
  });

  @override
  State<DestinationAddressScreen> createState() =>
      _DestinationAddressScreenState();
}

class _DestinationAddressScreenState extends State<DestinationAddressScreen> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.formModel.destinationWallet ?? '',
    );
    _controller.addListener(_handleInputChange);

    // Initial state log
    _logInput(_controller.text);
    _isValid = isValidSolanaAddress(_controller.text);
  }

  void _handleInputChange() {
    final input = _controller.text.trim();
    _logInput(input);

    final valid = isValidSolanaAddress(input);

    // Update form model
    widget.formModel.destinationWallet = input;

    // Only call setState if validity changes
    if (_isValid != valid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  void _logInput(String input) {
    skrLogger.i("📝 Input changed: \"$input\"");
    skrLogger.i("✅ Is valid address? ${isValidSolanaAddress(input)}");
  }

  bool isValidSolanaAddress(String address) {
    final regex = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');
    return regex.hasMatch(address);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleInputChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Enter Destination Wallet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Solana Wallet Address',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.formModel.destinationWallet = value;
              final valid = isValidSolanaAddress(value);
              skrLogger.i("🧪 Manual change: $value — valid? $valid");
              setState(() {
                _isValid = valid;
              });
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isValid ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(color: Colors.white),
              // Add this for safety, too:
              foregroundColor: Colors.white,
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
