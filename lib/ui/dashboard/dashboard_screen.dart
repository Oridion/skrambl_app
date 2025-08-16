import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/ui/dashboard/sections/dashboard_header.dart';
import 'package:skrambl_app/ui/dashboard/sections/dashboard_pods.dart';
import 'package:skrambl_app/ui/pods/all_pods_screen.dart';
import 'package:skrambl_app/ui/send/send_controller.dart';
import 'package:skrambl_app/utils/logger.dart';

/// A screen that handles Seed Vault authorization, wallet balance subscription,
/// and displays the dashboard UI once initialization completes.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  /// Performs the one-time startup sequence:
  /// 1️⃣ Ensures we have an AuthToken (prompts user if needed)
  /// 2️⃣ Retrieves the public key
  /// 3️⃣ Starts the balance provider
  Future<void> _initialize() async {
    final session = Provider.of<SeedVaultSessionManager>(context, listen: false);
    final balance = Provider.of<WalletBalanceProvider>(context, listen: false);

    // Get or request a valid AuthToken
    final authToken = await SeedVaultService.getValidToken(context);
    if (authToken == null) {
      throw Exception('Authorization declined or failed.');
    }
    session.setAuthToken(authToken);
    skrLogger.i('Seed Vault authorized.');

    // Fetch public key
    final pubkey = await SeedVaultService.getPublicKeyString(authToken: authToken);
    if (pubkey == null) {
      throw Exception('Failed to retrieve public key.');
    }
    skrLogger.i('Retrieved public key: $pubkey');

    // Start wallet balance stream
    balance.start(pubkey);
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
    final session = context.watch<SeedVaultSessionManager>();
    final balance = context.watch<WalletBalanceProvider>();
    final pubkey = balance.pubkey;
    final isLoading = balance.isLoading;
    final sol = balance.solBalance;
    final canSend = !isLoading && sol > 0;

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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 8),
              sliver: SliverToBoxAdapter(
                child: pubkey != null
                    ? DashboardHeader(authToken: session.authToken!, pubkey: pubkey)
                    : const Text("Failed to load wallet.", style: TextStyle(color: Colors.redAccent)),
              ),
            ),

            // Send button (between header and list)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canSend
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SendController(authToken: session.authToken!),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    child: const Text(
                      'SEND SOL',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),

            // Section title
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(26, 7, 26, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'LATEST DELIVERIES',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      // can't be const because it uses context
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AllPods()));
                      },
                      child: const Text(
                        'View more',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
