import 'package:flutter/material.dart';

/// A reusable async-aware "Next" button with built-in loading state.
/// - Disables itself when [enabled] is false
/// - Runs [onPressed] (async), shows a spinner, and re-enables when done
/// - Guarantees a minimum spinner time for nicer UX
class NextButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final bool enabled;
  final String label;
  final Duration minSpinnerDuration;
  final EdgeInsetsGeometry padding;
  final ButtonStyle? style;

  const NextButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.label = 'Next',
    this.minSpinnerDuration = const Duration(milliseconds: 220),
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    this.style,
  });

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final started = DateTime.now();
    try {
      await widget.onPressed();
    } finally {
      final elapsed = DateTime.now().difference(started);
      final remaining = widget.minSpinnerDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: widget.padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );

    return ElevatedButton(
      onPressed: (widget.enabled && !_loading) ? _handleTap : null,
      style: widget.style ?? defaultStyle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
        child: _loading
            ? const SizedBox(
                key: ValueKey('loading'),
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(widget.label, key: const ValueKey('label')),
      ),
    );
  }
}
