// lib/ui/send/widgets/scrambled_text.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ScrambledText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// Max duration for one scramble burst before resolving.
  final Duration maxDuration;

  /// Loop the scramble while the text stays the same (all phases).
  final bool loop;

  /// Delay between loops (only when [loop] is true and text unchanged).
  final Duration loopIdleDelay;

  /// Resolve quickly when `text` changes so phase switches are visible.
  final bool fastOnChange;

  const ScrambledText({
    super.key,
    required this.text,
    this.style,
    this.maxDuration = const Duration(milliseconds: 380),
    this.loop = true,
    this.loopIdleDelay = const Duration(seconds: 2),
    this.fastOnChange = true,
  });

  @override
  State<ScrambledText> createState() => _ScrambledTextState();
}

class _ScrambledTextState extends State<ScrambledText> {
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=+<>|!@#\$%^&*';
  final _rand = Random();

  String _displayed = '';
  Timer? _tick;
  Timer? _loopTimer;
  int _step = 0;
  int _stepsTotal = 0;
  late Duration _tickInterval;
  String _currentTarget = '';

  @override
  void initState() {
    super.initState();
    _startBurst(widget.text, fast: false);
  }

  @override
  void didUpdateWidget(covariant ScrambledText old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      // Phase changed: cancel loop, do a fast burst to new text
      _loopTimer?.cancel();
      _startBurst(widget.text, fast: widget.fastOnChange);
    } else if (widget.loop && _tick == null && _loopTimer == null) {
      // Same text, idle, looping requested: schedule another burst
      _scheduleLoop();
    }
  }

  void _startBurst(String target, {required bool fast}) {
    _cancelTick();
    _currentTarget = target;

    if (target.isEmpty) {
      setState(() => _displayed = '');
      return;
    }

    final len = target.length;
    _stepsTotal = (len <= 6) ? len : (len ~/ 2); // quick finish
    final ticks = _stepsTotal.clamp(3, 10);
    final total = fast ? widget.maxDuration : widget.maxDuration + const Duration(milliseconds: 80);
    _tickInterval = Duration(milliseconds: (total.inMilliseconds / ticks).ceil());

    setState(() => _displayed = _randomize(len));
    _step = 0;

    _tick = Timer.periodic(_tickInterval, (_) {
      _step++;
      if (_step >= _stepsTotal) {
        _cancelTick();
        if (mounted) setState(() => _displayed = target);

        if (widget.loop && mounted && _currentTarget == widget.text) {
          _scheduleLoop();
        }
        return;
      }

      final revealed = ((_step / _stepsTotal) * target.length).ceil();
      final buf = StringBuffer();
      for (var i = 0; i < target.length; i++) {
        if (i < revealed) {
          buf.write(target[i]);
        } else {
          buf.write(_chars[_rand.nextInt(_chars.length)]);
        }
      }
      if (mounted) setState(() => _displayed = buf.toString());
    });
  }

  void _scheduleLoop() {
    _loopTimer?.cancel();
    _loopTimer = Timer(widget.loopIdleDelay, () {
      if (!mounted) return;
      if (_currentTarget == widget.text) {
        _startBurst(widget.text, fast: false);
      }
    });
  }

  String _randomize(int length) {
    final buf = StringBuffer();
    for (var i = 0; i < length; i++) {
      buf.write(_chars[_rand.nextInt(_chars.length)]);
    }
    return buf.toString();
  }

  void _cancelTick() {
    _tick?.cancel();
    _tick = null;
  }

  @override
  void dispose() {
    _cancelTick();
    _loopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayed, style: widget.style);
  }
}
