import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/send/widgets/bullet_list.dart';
import 'package:skrambl_app/utils/colors.dart';

class ChoiceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String leadText;
  final List<String> bulletPoints;
  final String etaText;
  final Color accent;
  final Color background;
  final String? badgeText;
  final VoidCallback onSelected;
  final bool isHighlighted;

  const ChoiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.leadText,
    required this.bulletPoints,
    required this.etaText,
    required this.accent,
    required this.background,
    required this.onSelected,
    this.badgeText,
    this.isHighlighted = false,
  });

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    final black = Colors.black;
    final white = Colors.white;
    final borderRadius = BorderRadius.circular(10);

    // Subtle gradient fill only when highlighted
    final BoxDecoration? highlightedBg = widget.isHighlighted
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.background, widget.background.withOpacityCompat(0.92)],
            ),
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacityCompat(_pressed ? 0.12 : 0.16),
                blurRadius: _pressed ? 6 : 10,
                spreadRadius: 0.5,
                offset: const Offset(0, 3),
              ),
            ],
          )
        : null;

    final border = _GradientBorder(
      radius: 10,
      strokeWidth: widget.isHighlighted ? 3.5 : 2.0,
      colors: widget.isHighlighted
          ? [
              const Color.fromARGB(255, 63, 63, 63),
              const Color.fromARGB(255, 51, 51, 51),
              const Color.fromARGB(255, 83, 83, 83),
            ]
          : [const Color(0xFFDCDCDC), const Color(0xFFE4E4E4)],
    );

    return FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      mouseCursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        label: '${widget.title}, ${widget.etaText}',
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          scale: _pressed ? 0.985 : (widget.isHighlighted ? 1.01 : (_hovered ? 1.005 : 1.0)),
          child: CustomPaint(
            painter: border,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                decoration: highlightedBg,
                child: Material(
                  color: widget.background,
                  child: InkWell(
                    onHighlightChanged: (v) => setState(() => _pressed = v),
                    onHover: (v) => setState(() => _hovered = v),
                    onTap: widget.onSelected,
                    splashColor: widget.accent.withAlpha(80),
                    focusColor: widget.accent.withAlpha(40),
                    hoverColor: widget.accent.withAlpha(24),
                    customBorder: RoundedRectangleBorder(borderRadius: borderRadius),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon tile
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: black,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accent.withAlpha(28),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(widget.icon, color: white, size: 22),
                          ),
                          const SizedBox(width: 14),

                          // Texts
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                    if (widget.badgeText != null)
                                      Transform.translate(
                                        offset: const Offset(0, -2),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(255, 203, 176, 86), // tan badge
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Recommended',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // Lead sentence
                                Text(
                                  widget.leadText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withOpacityCompat(0.70),
                                  ),
                                ),

                                SizedBox(height: 12),

                                // Bullets
                                BulletList(
                                  items: widget.bulletPoints,
                                  spacing: 5,
                                  indent: 6,
                                  textStyle: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.25,
                                    color: Colors.black.withOpacityCompat(0.80),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  bulletSize: 5,
                                  bulletColor: Colors.black.withOpacityCompat(0.45),
                                ),
                                const SizedBox(height: 9),
                                Row(
                                  children: [
                                    _EtaChip(text: widget.etaText),
                                    const Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.black.withOpacityCompat(_focused ? 0.9 : 0.45),
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ——— Visual helpers ———

class _GradientBorder extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final List<Color> colors;

  _GradientBorder({required this.radius, required this.strokeWidth, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorder oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.strokeWidth != strokeWidth || oldDelegate.radius != radius;
}

class _EtaChip extends StatelessWidget {
  final String text;
  const _EtaChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 13, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
