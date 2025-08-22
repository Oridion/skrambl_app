// lib/ui/root_shell.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/providers/selected_wallet_provider.dart';
import 'package:skrambl_app/ui/burners/list_burners_screen.dart';
import 'package:skrambl_app/ui/dashboard/dashboard_screen.dart';
import 'package:skrambl_app/ui/pods/all_pods_screen.dart';
import 'package:skrambl_app/ui/shared/nav_icon_button.dart';

import 'package:skrambl_app/main.dart' show routeObserver;

class RootShell extends StatefulWidget {
  final int initialIndex;
  const RootShell({super.key, this.initialIndex = 0});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> with RouteAware {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    // Ensure primary is selected whenever RootShell shows up
    if (_index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SelectedWalletProvider>().selectPrimary();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }

    // If we land on Dashboard initially, ensure primary is selected once.
    if (_index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SelectedWalletProvider>().selectPrimary();
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Fired when a route above RootShell is popped (returning here)
  @override
  void didPopNext() {
    if (!mounted) return;
    if (_index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SelectedWalletProvider>().selectPrimary();
      });
    }
  }

  void _goTab(int i) {
    // If tapping the already-selected Dashboard tab, still enforce primary.
    if (_index == i) {
      if (i == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<SelectedWalletProvider>().selectPrimary();
        });
      }
      return;
    }

    setState(() => _index = i);

    // After switching to Dashboard, enforce primary.
    if (i == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<SelectedWalletProvider>().selectPrimary();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _KeepAlive(child: Dashboard()),
      _KeepAlive(child: AllPods()),
      _KeepAlive(child: BurnersScreen()),
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
                    NavIconButton(
                      tooltip: 'Dashboard',
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      selected: _index == 0,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _goTab(0);
                      },
                    ),
                    SizedBox(
                      width: 80,
                      child: NavIconButton(
                        tooltip: 'Pods',
                        icon: AppConstants.skramblIconOutlined,
                        activeIcon: AppConstants.skramblIcon,
                        selected: _index == 1,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _goTab(1);
                        },
                      ),
                    ),
                    NavIconButton(
                      tooltip: 'Burners',
                      icon: Icons.local_fire_department_outlined,
                      activeIcon: Icons.local_fire_department,
                      selected: _index == 2,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _goTab(2);
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
