import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

class NavIconButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;

  const NavIconButton({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Tooltip(
        message: tooltip, // hidden label for a11y/long-press
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 56, // perfect pill width
              height: 44, // perfect pill height
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected ? Colors.white : cs.onSurface.withOpacityCompat(0.75),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
