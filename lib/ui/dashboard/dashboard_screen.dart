//NEW WAY
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/ui/dashboard/sections/dashboard_header.dart';
import 'package:skrambl_app/ui/send/send_flow_screen.dart';
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
    final session = Provider.of<SeedVaultSessionManager>(
      context,
      listen: false,
    );
    final balance = Provider.of<WalletBalanceProvider>(context, listen: false);

    // 1️⃣ Get or request a valid AuthToken
    final authToken = await SeedVaultService.getValidToken(context);
    if (authToken == null) {
      throw Exception('Authorization declined or failed.');
    }
    session.setAuthToken(authToken);
    skrLogger.i('✅ Seed Vault authorized.');

    // 2️⃣ Fetch public key
    final pubkey = await SeedVaultService.getPublicKeyString(
      authToken: authToken,
    );
    if (pubkey == null) {
      throw Exception('Failed to retrieve public key.');
    }
    skrLogger.i('⚡️ Retrieved public key: $pubkey');

    // 3️⃣ Kick off wallet balance stream
    balance.start(pubkey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Loading / authorizing
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              if (pubkey != null)
                DashboardHeader(authToken: session.authToken!, pubkey: pubkey),
              const Spacer(),
              ElevatedButton(
                onPressed: canSend
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SendFlowScreen(authToken: session.authToken!),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('SEND SOL'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
