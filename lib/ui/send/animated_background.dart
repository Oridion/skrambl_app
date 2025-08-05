import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final bool isActive;

  const AnimatedBackground({super.key, this.isActive = true});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  final Random _random = Random();
  final List<Widget> _glitchSquares = [];

  @override
  void initState() {
    super.initState();
    // delay building squares until after layout is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _buildSquares(size);
    });
  }

  void _buildSquares(Size screenSize) {
    if (!widget.isActive) return;
    final squares = List.generate(1000, (index) {
      final size = _random.nextInt(6) + 4.0;
      final left = _random.nextDouble() * screenSize.width;
      final top = _random.nextDouble() * screenSize.height;

      return FadeSquare(
        left: left,
        top: top,
        size: size,
        delay: Duration(milliseconds: _random.nextInt(2000)),
        duration: Duration(milliseconds: 2000 + _random.nextInt(2000)),
        isActive: widget.isActive,
      );
    });

    setState(() => _glitchSquares.addAll(squares));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: _glitchSquares);
  }
}

class FadeSquare extends StatefulWidget {
  final double left;
  final double top;
  final double size;
  final Duration delay;
  final Duration duration;
  final bool isActive;

  const FadeSquare({
    super.key,
    required this.left,
    required this.top,
    required this.size,
    required this.delay,
    required this.duration,
    required this.isActive,
  });

  @override
  State<FadeSquare> createState() => _FadeSquareState();
}

class _FadeSquareState extends State<FadeSquare>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted && widget.isActive) {
        _controller.repeat(reverse: false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 180, 180, 180),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }
}
