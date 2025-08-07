import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana/solana.dart';
import '../send_form_model.dart';

class SkrambledDestinationScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final SendFormModel formModel;

  const SkrambledDestinationScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.formModel,
  });

  @override
  State<SkrambledDestinationScreen> createState() =>
      _SkrambledDestinationScreenState();
}

class _SkrambledDestinationScreenState
    extends State<SkrambledDestinationScreen> {
  late final TextEditingController _controller;
  String? _error;
  bool _isValid = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.formModel.destinationWallet ?? '',
    );

    // Listen for changes and validate in real-time
    _controller.addListener(() {
      final current = _controller.text.trim();
      skrLogger.i(current);

      // Cancel existing debounce
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        final isNowValid = _isSolanaAddress(current);

        setState(() {
          _isValid = isNowValid;
        });

        if (_error != null) {
          setState(() {
            _error = null;
          });
        }
      });
    });

    // Initialize state
    _isValid = _isSolanaAddress(_controller.text);
  }

  bool _isSolanaAddress(String address) {
    try {
      Ed25519HDPublicKey.fromBase58(address);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _handleNext() {
    if (!_isValid) {
      setState(() => _error = 'Invalid wallet address');
      return;
    }

    FocusScope.of(context).unfocus(); // Dismiss keyboard
    widget.formModel.destinationWallet = _controller.text.trim();
    widget.onNext();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter Destination Wallet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Solana Wallet Address',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                tooltip: 'Paste',
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data != null && data.text != null) {
                    _controller.text = data.text!.trim();
                  }
                },
              ),
            ),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 2,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),

          if (_controller.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    _isValid ? Icons.check : Icons.error,
                    color: _isValid
                        ? const Color.fromARGB(255, 61, 158, 64)
                        : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isValid
                        ? 'Valid Solana address'
                        : 'Invalid Solana address',
                    style: TextStyle(
                      color: _isValid
                          ? const Color.fromARGB(255, 49, 128, 52)
                          : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: widget.onBack, child: const Text('Back')),
              ElevatedButton(
                onPressed: _isValid ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
