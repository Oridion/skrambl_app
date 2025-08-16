import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/providers/minute_ticker.dart';
import 'package:skrambl_app/providers/pod_watcher_manager.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/solana/solana_ws_service.dart';
import 'package:skrambl_app/ui/root_shell.dart';
import 'data/local_database.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/wallet_balance_manager.dart';
import 'package:skrambl_app/ui/errors/seed_vault_required.dart';
import 'package:skrambl_app/data/burner_repository.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );

  final db = LocalDatabase();
  final podDao = PodDao(db);

  final seedVaultProvider = SeedVaultSessionManager();
  await seedVaultProvider.initialize();

  final balanceProvider = WalletBalanceProvider();

  final sharedWs = SolanaWsService();
  final watcherManager = PodWatcherManager(podDao, wsService: sharedWs);

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalDatabase>.value(value: db),
        Provider<PodDao>.value(value: podDao),
        Provider<SolanaWsService>.value(value: sharedWs),
        ChangeNotifierProvider(create: (_) => seedVaultProvider),
        ChangeNotifierProvider(create: (_) => balanceProvider),
        ChangeNotifierProvider(create: (_) => TransactionStatusProvider()),
        ChangeNotifierProvider(create: (_) => MinuteTicker()),
        ChangeNotifierProvider<PodWatcherManager>.value(value: watcherManager),
        Provider<BurnerRepository>(
          create: (ctx) {
            final token = ctx.read<SeedVaultSessionManager>().authToken;
            if (token == null) {
              // If this can happen on cold start, you can throw or return a dummy.
              // Since you call initialize() before runApp, token should be ready.
              throw StateError('AuthToken is not available for BurnerRepository.');
            }
            return BurnerRepository(manager: BurnerWalletManager(authToken: token));
          },
        ),
      ],
      child: const AppLifecycleHandler(child: SkramblApp()),
    ),
  );

  // Start the watcher after providers are set up
  watcherManager.start();
}

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final watcher = context.read<PodWatcherManager>();
    if (state == AppLifecycleState.resumed) {
      watcher.start();
      final seedVault = Provider.of<SeedVaultSessionManager>(context, listen: false);
      final balance = Provider.of<WalletBalanceProvider>(context, listen: false);

      if (seedVault.authToken == null) {
        //skrLogger.i("🔁 App resumed. Re-checking authToken...");
        seedVault.initialize();
        balance.stop();
      }
    }
    if (state == AppLifecycleState.paused) watcher.stop();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class SkramblApp extends StatelessWidget {
  const SkramblApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seedVault = Provider.of<SeedVaultSessionManager>(context);
    final seedVaultAvailable = seedVault.isAvailable;

    return MaterialApp(
      title: 'SKRAMBL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 239, 240, 242),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle.dark, // 👈 Ensure this is here
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.spaceGrotesk(fontSize: 30),
          titleMedium: GoogleFonts.roboto(fontSize: 20),
          bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 16),
          labelSmall: GoogleFonts.firaCode(fontSize: 12),
          bodySmall: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            letterSpacing: 0.2,
          ),
        ),
      ),
      home: seedVaultAvailable ? const RootShell() : const SeedVaultRequiredScreen(),
    );
  }
}
