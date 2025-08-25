import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/logger.dart';

class TimelineCountdownToEta extends StatefulWidget {
  final DateTime submittedAt;
  final int delaySeconds; // seconds of user-selected delay
  final TextStyle? style;
  final Key? stableKey; // key to preserve identity across rebuilds

  const TimelineCountdownToEta({
    super.key,
    required this.submittedAt,
    required this.delaySeconds,
    this.style,
    this.stableKey,
  });

  @override
  State<TimelineCountdownToEta> createState() => _TimelineCountdownToEtaState();
}

class _TimelineCountdownToEtaState extends State<TimelineCountdownToEta> {
  late DateTime _eta;
  late Duration _remaining = _eta.difference(DateTime.now());
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _recompute();
    _start();
  }

  @override
  void didUpdateWidget(TimelineCountdownToEta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submittedAt != widget.submittedAt || oldWidget.delaySeconds != widget.delaySeconds) {
      _tick?.cancel();
      _recompute();
      _start();
    }
  }

  void _recompute() {
    _eta = widget.submittedAt.add(Duration(seconds: widget.delaySeconds));
    skrLogger.i("ETA: $_eta");
    _remaining = _eta.difference(DateTime.now());
  }

  void _start() {
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() => _remaining = _eta.difference(now));
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final msg = _format(_remaining);
    return Text(msg, style: widget.style);
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _format(Duration d) {
    // <= 0 => show your special message
    if (d <= Duration.zero) {
      return 'Delivering soon. Please stand by.';
    }
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return 'ETA in ~${_two(h)}:${_two(m)}:${_two(s)}';
    return 'ETA in ~$m:${_two(s)}';
  }
}
