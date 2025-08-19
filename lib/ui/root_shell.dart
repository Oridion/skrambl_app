// lib/ui/root_shell.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/ui/burners/list_burners_screen.dart';
import 'package:skrambl_app/ui/dashboard/dashboard_screen.dart';
import 'package:skrambl_app/ui/pods/all_pods_screen.dart';
import 'package:skrambl_app/utils/colors.dart';

class RootShell extends StatefulWidget {
  final int initialIndex;
  const RootShell({super.key, this.initialIndex = 0});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _KeepAlive(child: Dashboard()),
      _KeepAlive(child: BurnersScreen()),
      _KeepAlive(child: AllPods()),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 80),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withAlpha(18)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NavIconButton(
                      tooltip: 'Dashboard',
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      selected: _index == 0,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _index = 0);
                      },
                    ),

                    SizedBox(
                      width: 80,
                      child: _NavIconButton(
                        tooltip: 'Pods',
                        icon: AppConstants.skramblIconOutlined,
                        activeIcon: AppConstants.skramblIcon,
                        selected: _index == 2,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _index = 2);
                        },
                      ),
                    ),
                    _NavIconButton(
                      tooltip: 'Burners',
                      icon: Icons.local_fire_department_outlined,
                      activeIcon: Icons.local_fire_department,
                      selected: _index == 1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _index = 1);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;

  const _NavIconButton({
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

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});
  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
