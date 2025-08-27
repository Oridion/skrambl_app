import 'package:flutter/material.dart';
import 'package:skrambl_app/utils/colors.dart';

/// Segmented (pill) tabs for the destination step.
/// Usage:
/// SegmentedTabs(
///   controller: _tabCtrl,
///   burnerCount: _burners.length, // or 0 if not loaded yet
/// )
class SegmentedTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final int burnerCount;
  final Color background;
  final Color border;
  final Color selectedFill;
  final Color selectedText;
  final Color text;

  const SegmentedTabs({
    super.key,
    required this.controller,
    required this.burnerCount,
    this.background = const Color(0xFFE7E7E7),
    this.border = const Color(0x1F000000), // black12-ish
    this.selectedFill = Colors.black,
    this.selectedText = Colors.white,
    this.text = Colors.black,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight - 8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: selectedFill, borderRadius: BorderRadius.circular(5)),
        labelColor: selectedText,
        unselectedLabelColor: text,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        splashFactory: NoSplash.splashFactory, // cleaner taps
        //overlayColor: MaterialStateProperty.all(Colors.transparent),
        tabs: [
          _TabChip(icon: Icons.content_paste, text: 'Custom address'),
          _TabChip(
            icon: Icons.local_fire_department,
            text: 'Burner wallet',
            badge: burnerCount > 0 ? burnerCount : null,
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final int? badge;

  const _TabChip({required this.icon, required this.text, this.badge});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 36, // bigger hit area
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (badge != null) ...[const SizedBox(width: 8), _Badge(count: badge!)],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final String label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacityCompat(0.16),
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
