import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ScrambledText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;

  const ScrambledText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 80), // Slower speed
  });

  @override
  State<ScrambledText> createState() => _ScrambledTextState();
}

class _ScrambledTextState extends State<ScrambledText> {
  late String _displayed;
  Timer? _scrambleTimer;
  Timer? _loopTimer;
  int _step = 0;
  final _rand = Random();

  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=+<>|!@#\$%^&*';

  @override
  void initState() {
    super.initState();
    _startScramble();
  }

  void _startScramble() {
    _step = 0;
    _displayed = _randomize(widget.text.length);
    _scrambleTimer = Timer.periodic(widget.speed, (_) => _scrambleStep());
  }

  void _scrambleStep() {
    if (_step >= widget.text.length) {
      _scrambleTimer?.cancel();

      // Loop again after 3 seconds
      _loopTimer = Timer(const Duration(seconds: 3), _startScramble);
      return;
    }

    setState(() {
      _displayed = widget.text.characters
          .mapIndexed(
            (i, c) => i <= _step ? c : _chars[_rand.nextInt(_chars.length)],
          )
          .join();
    });

    _step++;
  }

  String _randomize(int length) {
    return List.generate(
      length,
      (_) => _chars[_rand.nextInt(_chars.length)],
    ).join();
  }

  @override
  void dispose() {
    _scrambleTimer?.cancel();
    _loopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayed, style: widget.style);
  }
}

extension<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int, T) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}
