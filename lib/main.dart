import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/providers/burner_balances_provider.dart';
import 'package:skrambl_app/providers/minute_ticker.dart';
import 'package:skrambl_app/providers/network_fee_provider.dart';
import 'package:skrambl_app/providers/pod_watcher_manager.dart';
import 'package:skrambl_app/providers/price_provider.dart';
import 'package:skrambl_app/providers/selected_wallet_provider.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/services/network_fee_service.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/solana/solana_ws_service.dart';
import 'package:skrambl_app/ui/root_shell.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'data/local_database.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';
import 'package:skrambl_app/ui/errors/seed_vault_required.dart';
import 'package:skrambl_app/data/burner_repository.dart';
import 'package:skrambl_app/services/burner_wallet_management.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );

  final db = LocalDatabase();
  final podDao = PodDao(db);
  final burnerDao = BurnerDao(db);
  final seedVault = SeedVaultSessionManager();
  await seedVault.initialize();

  final ws = SolanaWsService();

  runApp(
    MultiProvider(
      providers: [
        // Base services / DAOs
        Provider<LocalDatabase>.value(value: db),
        Provider<PodDao>.value(value: podDao),
        Provider<BurnerDao>.value(value: burnerDao),
        Provider<SolanaWsService>.value(value: ws),

        // App state
        ChangeNotifierProvider(create: (_) => PriceProvider()),
        ChangeNotifierProvider<SeedVaultSessionManager>.value(value: seedVault),

        // Selection FIRST
        ChangeNotifierProvider(create: (_) => SelectedWalletProvider()),

        // WalletProvider follows selection + reacts to price
        ChangeNotifierProxyProvider2<PriceProvider, SelectedWalletProvider, WalletProvider>(
          create: (ctx) => WalletProvider(ctx.read<PriceProvider>()),
          update: (ctx, price, selected, wallet) {
            final w = wallet ?? WalletProvider(price);
            w.attachPriceProvider(price);
            w.setAccount(selected.pubkey); // null clears, non-null switches
            return w;
          },
        ),

        // Tx status must come before watcher manager
        ChangeNotifierProvider(create: (_) => TransactionStatusProvider()),

        // Network fee
        ChangeNotifierProvider(create: (_) => NetworkFeeProvider(NetworkFeeService())),

        // Pod watcher
        ChangeNotifierProvider<PodWatcherManager>(
          create: (ctx) {
            final dao = ctx.read<PodDao>();
            final ws = ctx.read<SolanaWsService>();
            final status = ctx.read<TransactionStatusProvider>();
            final mgr = PodWatcherManager(
              dao,
              wsService: ws,
              onPhase: (podId, phase) => status.onPhaseFromWatcher(podId, phase),
            );
            mgr.start();
            return mgr;
          },
        ),

        // The rest
        ChangeNotifierProvider(create: (_) => MinuteTicker()),
        Provider<BurnerWalletManager>(create: (_) => BurnerWalletManager()),
        Provider<BurnerRepository>(
          create: (ctx) =>
              BurnerRepository(manager: ctx.read<BurnerWalletManager>(), dao: ctx.read<BurnerDao>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BurnerBalancesProvider(
            dao: ctx.read<BurnerDao>(),
            rpcHttpUrl: AppConstants.rawAPIURL,
            refreshEvery: const Duration(seconds: 45),
          ),
        ),
      ],
      child: const AppLifecycleHandler(child: SkramblApp()),
    ),
  );
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

    // Warm burner cache once app is up and Providers exist
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = context.read<BurnerRepository>();
      await repo.warmCacheFromDb();

      if (!mounted) return;
      final seedVault = context.read<SeedVaultSessionManager>();
      if (seedVault.authToken == null) {
        await seedVault.initialize();
      }

      final token = seedVault.authToken;
      if (token != null) {
        final pk = await SeedVaultService.getPublicKey(authToken: token);
        if (pk != null && mounted) {
          context.read<SelectedWalletProvider>().setPrimary(pk.toBase58());
          skrLogger.i("Set primary to ${pk.toBase58()}");
        }
      }

      if (!mounted) return;
      await context.read<NetworkFeeProvider>().refresh();
    });
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
      final wp = Provider.of<WalletProvider>(context, listen: false);

      if (seedVault.authToken == null) {
        seedVault.initialize();
        wp.setAccount(null);
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
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
          labelSmall: GoogleFonts.spaceGrotesk(fontSize: 12),
          //labelLarge: GoogleFonts.spaceGrotesk(fontSize: 30),
          bodySmall: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            letterSpacing: 0.2,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating, // makes it float above UI
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // pill style
          ),
          backgroundColor: Colors.black87,
          contentTextStyle: const TextStyle(color: Colors.white),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12, // bottom margin
          ),
        ),
      ),
      navigatorObservers: [routeObserver],
      home: seedVaultAvailable ? const RootShell() : const SeedVaultRequiredScreen(),
    );
  }
}
