import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/selected_wallet_provider.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/ui/dashboard/sections/dashboard_pods.dart';
import 'package:skrambl_app/ui/dashboard/widgets/header_sliver.dart';
import 'package:skrambl_app/ui/dashboard/widgets/section_title.dart';
import 'package:skrambl_app/ui/dashboard/widgets/send_button.dart';

/// A screen that handles Seed Vault authorization, wallet balance subscription,
/// and displays the dashboard UI once initialization completes.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with RouteAware {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
    context.read<SelectedWalletProvider>().selectPrimary();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SelectedWalletProvider>().selectPrimary();
    });
  }

  Future<void> _initialize() async {
    final session = context.read<SeedVaultSessionManager>();
    final authToken = await SeedVaultService.getValidToken(context);
    if (authToken == null) throw Exception('Authorization declined or failed.');
    session.setAuthToken(authToken);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Loading / authorizing
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          // Display retry UI on error
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initFuture = _initialize();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        // Initialization succeeded: show dashboard
        return const _DashboardContent();
      },
    );
  }
}

/// Separated content widget: assumes authorization & balance stream are active.
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    // add bottom padding so last items aren't hidden behind the footer nav
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    const footerHeight = kBottomNavigationBarHeight; // ~80 in M3
    final bottomPad = footerHeight + bottomSafe + 24;

    return Scaffold(
      // Let content scroll behind the footer; we'll pad manually
      body: SafeArea(
        top: true,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Header
            HeaderSliver(),
            // Send button (between header and list)
            SendButtonSliver(),
            // Section title
            SectionTitleSliver(),
            // Pods list as a Sliver (scrollable)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: PodsSliver(), // <— see below
            ),
            // Bottom padding so we can scroll past/behind the footer
            SliverToBoxAdapter(child: SizedBox(height: bottomPad)),
          ],
        ),
      ),
    );
  }
}
