// Dart SDK
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/ui/send/screens/standard/standard_summary_screen.dart';
import 'package:skrambl_app/ui/send/widgets/with_wallet_balance.dart';

// Third-party
import 'package:solana/solana.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

// App: data & models
import 'package:skrambl_app/data/burner_repository.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/data/skrambl_entity.dart';
import 'package:skrambl_app/models/launch_pod_request.dart';
import 'package:skrambl_app/models/send_form_model.dart';

// App: routes
import 'package:skrambl_app/routes/send_routes.dart';

// App: services
import 'package:skrambl_app/api/launch_pod_service.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/solana/pod_tx_helper.dart';
import 'package:skrambl_app/solana/send_skrambled_transaction.dart';

// App: UI
import 'package:skrambl_app/ui/send/helpers/status_result.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skrambled_status_screen.dart';
import 'package:skrambl_app/ui/send/screens/standard/standard_amount_screen.dart';
import 'package:skrambl_app/ui/send/screens/send_type_selection_screen.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skrambled_amount_screen.dart';
import 'package:skrambl_app/ui/send/screens/send_destination_screen.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skrambled_summary_screen.dart';

// App: utils
import 'package:skrambl_app/utils/launcher.dart';
import 'package:skrambl_app/utils/logger.dart';

class SendController extends StatefulWidget {
  final AuthToken authToken;
  final String? fromWalletOverride;
  final int? fromBurnerIndexOverride; // only when using burner
  const SendController({
    super.key,
    required this.authToken,
    this.fromWalletOverride,
    this.fromBurnerIndexOverride,
  });

  @override
  State<SendController> createState() => _SendControllerState();
}

class _SendControllerState extends State<SendController> {
  final PageController _pageController = PageController();
  final SendFormModel _formModel = SendFormModel();
  String? _currentDraftId; // Draft db id
  bool _canResend = false; // Controls send button label/handler
  int _currentPage = 0;
  bool _isSubmitting = false;
  String _appBarTitle = 'Send';
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initUserWallet();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late final _TitleNavObserver _navObserver = _TitleNavObserver(onTopRouteChange: _setTitleSafely);

  void _setTitleSafely(String? routeName) {
    skrLogger.i("CHANGE");
    final newTitle = titleFor(routeName);
    if (!mounted) return;

    // If we're in the middle of a frame/build, defer to after this frame.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() => _appBarTitle = newTitle);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _appBarTitle = newTitle);
      });
    }
  }

  Future<void> _initUserWallet() async {
    try {
      if (widget.fromWalletOverride != null) {
        _formModel.userWallet = widget.fromWalletOverride;
        _formModel.userBurnerIndex = widget.fromBurnerIndexOverride; // may be null
        setState(() {}); // if UI depends on it
        return;
      }

      // Fallback: primary wallet from Seed Vault
      final pubkey = await SeedVaultService.getPublicKeyString(authToken: widget.authToken);
      if (!mounted) return;
      if (pubkey == null) {
        skrLogger.e('Failed to retrieve public key.');
        return;
      }
      _formModel.userWallet = pubkey;
      _formModel.userBurnerIndex = null;
      setState(() {});
    } catch (e, st) {
      skrLogger.e('Error getting public key: $e\n$st');
    }
  }

  void nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<SendStatusResult?> _pushStatus({
    required Uint8List txBytes,
    required Uint8List signature,
    required String podPdaBase58,
    required String destination,
    required double amount,
    required String localId,
  }) {
    return Navigator.of(context).push<SendStatusResult>(
      MaterialPageRoute(
        builder: (_) => SendStatusScreen(
          localId: localId,
          txBytes: txBytes,
          signature: signature,
          podPDA: Ed25519HDPublicKey.fromBase58(podPdaBase58),
          destination: destination,
          amount: amount,
        ),
      ),
    );
  }

  Future<void> _handleStatusResult(SendStatusResult? result) async {
    if (!mounted || result == null) return;
    setState(() => _isSubmitting = false);

    switch (result.type) {
      case SendStatusResultType.failed:
        setState(() => _canResend = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message ?? 'Send failed. Please try again.')));
        break;
      case SendStatusResultType.submitted:
        break;
      case SendStatusResultType.canceled:
        break;
    }
  }

  //SEND SKRAMBLED TRANSACTION
  void sendSkrambled() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _canResend = false;
    });

    final dao = context.read<PodDao>();

    // Check if Seed Vault is available
    final isAvailable = await SeedVault.instance.isAvailable(allowSimulated: true);
    if (!isAvailable) throw Exception("Seed Vault not available");

    // Ask the user to grant SKRAMBL permission to use Seed Vault
    final permissionGranted = await SeedVaultService.requestPermission();
    if (!permissionGranted) throw Exception("Seed Vault permission denied");

    // Get a valid AuthToken (either reuse or prompt the authorizeSeed dialog)
    if (!mounted) return;
    final token = await SeedVaultService.getValidToken(context);
    if (token == null) {
      skrLogger.e("❌ Seed Vault authorization denied.");
      setState(() => _isSubmitting = false);
      return;
    }

    // Derive the public key with that token
    final userWallet = await SeedVaultService.getPublicKey(
      authToken: token, // ← use `token`, not `widget.authToken`
    );
    if (userWallet == null) {
      skrLogger.e("❌ Failed to fetch public key.");
      setState(() => _isSubmitting = false);
      return;
    }

    // Build the payload
    const lamportsPerSol = 1000000000;
    var podId = generatePodId(); //POD ID
    var passcode = generatePasscode(); //Emergency Passcode

    final payload = LaunchPodRequest(
      id: podId,
      destination: _formModel.destinationWallet!,
      lamports: (_formModel.amount! * lamportsPerSol).round(),
      userWallet: userWallet.toString(),
      delay: _formModel.delaySeconds,
      passcode: passcode,
      showMemo: 0,
      returnType: "message",
    );
    //skrLogger.i("📦 Payload: $payload");

    // Derive the Pod PDA
    var podPDA = await getPodPDA(id: podId, creator: userWallet);
    skrLogger.i("POD PDA: ${podPDA.toString()}");

    // Insert draft pod into the database
    // Note: `podId` is used as a local identifier, not the on-chain
    // PDA. It should be unique for each pod.
    skrLogger.i("Creating draft pod with ID: $podId");
    final localId = await dao.createDraft(
      creator: userWallet.toString(), // the Seed Vault pubkey
      podId: podId,
      podPda: podPDA.toBase58(),
      lamports: (_formModel.amount! * lamportsPerSol).round(),
      mode: _formModel.delaySeconds == 0 ? 0 : 1, // 0=instant, 1=delay
      delaySeconds: _formModel.delaySeconds,
      showMemo: false,
      escapeCode: passcode, // optional, for local recovery
      destination: _formModel.destinationWallet!,
    );

    setState(() {
      _currentDraftId = localId; // Store the local draft ID
      _canResend = false;
    });

    // Fetch the unsigned tx
    // final unsignedBase64Tx = await fetchUnsignedLaunchTx(payload);
    // await dao.attachUnsignedMessage(
    //   id: _currentDraftId!,
    //   podPda: podPDA.toBase58(),
    //   unsignedMessageB64: unsignedBase64Tx,
    // );
    late final String unsignedBase64Tx;
    try {
      unsignedBase64Tx = await fetchUnsignedLaunchTx(payload);
      await dao.attachUnsignedMessage(id: _currentDraftId!, unsignedMessageB64: unsignedBase64Tx);
      // decode, patch, sign, push status...
    } catch (e) {
      setState(() => _canResend = true);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Send failed. You can retry without rebuilding.')));
      skrLogger.e('Send failed: $e');
      setState(() => _isSubmitting = false);
      return;
    }

    // Decode and sign the transaction
    // Note: we need to update the blockhash before signing
    try {
      var txBytes = base64Decode(unsignedBase64Tx);
      txBytes = await updateBlockhashInMessage(txBytes);
      final signature = await SeedVaultService.signMessage(
        messageBytes: txBytes,
        authToken: token, // Passing authToken from getValidToken
      );
      if (signature.length != 64) {
        setState(() {
          _canResend = true;
          _isSubmitting = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid signature. Try again.')));
        return;
      }

      skrLogger.i("Signature: $signature");

      if (!context.mounted) return;

      final result = await _pushStatus(
        txBytes: txBytes,
        signature: signature,
        podPdaBase58: podPDA.toBase58(),
        destination: _formModel.destinationWallet!,
        amount: _formModel.amount!,
        localId: _currentDraftId!,
      );

      await _handleStatusResult(result);
    } catch (e) {
      // Don’t discard the draft; we want to RESEND
      setState(() => _canResend = true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Send failed. You can retry without rebuilding the transaction.')),
      );
      skrLogger.e('Send failed: $e');
      setState(() => _isSubmitting = false);
      return;
    }
  }

  // Resend the transaction if it failed
  // We need to update blockhash and re-sign
  Future<void> _resendFromDraft() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final dao = context.read<PodDao>();

    try {
      final pod = await dao.watchById(_currentDraftId!).first;
      if (pod == null) {
        setState(() => _canResend = false);
        setState(() => _isSubmitting = false);
        return;
      }

      // Case A: already submitted → retry queue only
      if (pod.launchSig != null && pod.status == PodStatus.submitted.index) {
        if (!mounted) return;
        final result = await Navigator.push<SendStatusResult>(
          context,
          MaterialPageRoute(
            builder: (_) => SendStatusScreen.queueOnly(
              localId: _currentDraftId!,
              podPDA: Ed25519HDPublicKey.fromBase58(pod.podPda!),
              destination: _formModel.destinationWallet!,
              amount: _formModel.amount!,
              launchSig: pod.launchSig!,
            ),
          ),
        );
        await _handleStatusResult(result);
        return;
      }

      // Case A2: already past submitted (scrambling/delivering) → just watch
      if (pod.status == PodStatus.scrambling.index || pod.status == PodStatus.delivering.index) {
        if (!mounted) return;
        final result = await Navigator.push<SendStatusResult>(
          context,
          MaterialPageRoute(
            builder: (_) => SendStatusScreen.queueOnly(
              localId: _currentDraftId!,
              podPDA: Ed25519HDPublicKey.fromBase58(pod.podPda!),
              destination: _formModel.destinationWallet!,
              amount: _formModel.amount!,
              launchSig: pod.launchSig ?? '', // not used in watch-only path
            ),
          ),
        );
        await _handleStatusResult(result);
        return;
      }

      // Case B: not submitted yet → rebuild unsigned, sign, send
      if (pod.unsignedMessageB64 == null) {
        // Nothing to resend locally; you could re-fetch from Lambda here if desired.
        setState(() => _canResend = true);
        setState(() => _isSubmitting = false);
        return;
      }

      var txBytes = base64Decode(pod.unsignedMessageB64!);
      txBytes = await updateBlockhashInMessage(txBytes);

      if (!mounted) return;
      final token = await SeedVaultService.getValidToken(context);
      if (token == null) {
        setState(() => _canResend = true);
        setState(() => _isSubmitting = false);
        return;
      }
      final signature = await SeedVaultService.signMessage(messageBytes: txBytes, authToken: token);
      if (signature.length != 64) {
        setState(() => _canResend = true);
        setState(() => _isSubmitting = false);
        return;
      }

      final result = await _pushStatus(
        txBytes: txBytes,
        signature: signature,
        podPdaBase58: pod.podPda!,
        destination: _formModel.destinationWallet!,
        amount: _formModel.amount!,
        localId: _currentDraftId!,
      );

      await _handleStatusResult(result);
    } catch (e) {
      skrLogger.e('Resend prep failed: $e');
      setState(() => _canResend = true);
      setState(() => _isSubmitting = false);
    }
  }

  List<Widget> get _pages {
    // Always start with type selection
    final pages = <Widget>[SendTypeSelectionScreen(onNext: nextPage, formModel: _formModel)];
    final repo = context.read<BurnerRepository>();
    if (_formModel.isSkrambled == true) {
      pages.addAll([
        SendDestinationScreen(
          onNext: nextPage,
          onBack: prevPage,
          formModel: _formModel,
          fetchBurners: repo.fetchBurners,
          createBurner: repo.createBurner,
        ),
        SkrambledAmountScreen(onNext: nextPage, onBack: prevPage, formModel: _formModel),
        SkrambledSummaryScreen(
          key: ValueKey('summary-$_canResend-${_currentDraftId ?? ""}'),
          onSend: _canResend ? _resendFromDraft : sendSkrambled,
          onBack: prevPage,
          canResend: _canResend,
          isSubmitting: _isSubmitting,
          formModel: _formModel,
        ),
      ]);
    } else {
      pages.add(StandardAmountScreen(onBack: prevPage, onNext: nextPage, formModel: _formModel));
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        leading: BackButton(
          onPressed: () async {
            final didPop = await _navKey.currentState?.maybePop() ?? false;
            if (!didPop && mounted) Navigator.of(context).maybePop();
          },
        ),
      ),
      body: Navigator(
        key: _navKey,
        observers: [_navObserver],
        initialRoute: SendRoutes.type,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // 1) choose type
            case SendRoutes.type:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => SendTypeSelectionScreen(
                  formModel: _formModel,
                  onNext: () => _navKey.currentState!.pushNamed(SendRoutes.destination),
                ),
              );

            // 2) destination (shared)
            case SendRoutes.destination:
              {
                final repo = context.read<BurnerRepository>();
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => SendDestinationScreen(
                    // NOTE: we reuse your existing destination screen for both flows.
                    // If standard needs a different destination UI, make a StandardDestinationScreen and branch here.
                    formModel: _formModel,
                    onBack: () => _navKey.currentState!.maybePop(),
                    onNext: () {
                      if (_formModel.isSkrambled == true) {
                        _navKey.currentState!.pushNamed(SendRoutes.skAmount);
                      } else {
                        // jump to standard route (single page or your new 2-step)
                        _navKey.currentState!.pushNamed(SendRoutes.stAmount);
                      }
                    },
                    fetchBurners: repo.fetchBurners,
                    createBurner: repo.createBurner,
                  ),
                );
              }

            // 3a) SKRAMBL amount
            case SendRoutes.skAmount:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => SkrambledAmountScreen(
                  formModel: _formModel,
                  onBack: () => _navKey.currentState!.maybePop(),
                  onNext: () => _navKey.currentState!.pushNamed(SendRoutes.skSummary),
                ),
              );

            // 4a) SKRAMBL summary
            case SendRoutes.skSummary:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => SkrambledSummaryScreen(
                  key: ValueKey('summary-$_canResend-${_currentDraftId ?? ""}'),
                  formModel: _formModel,
                  canResend: _canResend,
                  isSubmitting: _isSubmitting,
                  onBack: () => _navKey.currentState!.maybePop(),
                  onSend: _canResend ? _resendFromDraft : sendSkrambled,
                ),
              );

            // 3b) STANDARD Amount path
            case SendRoutes.stAmount:
              final fromPk = _formModel.userWallet!; // primary or burner (you set this earlier)
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => WithWalletBalance(
                  pubkey: fromPk,
                  child: StandardAmountScreen(
                    formModel: _formModel,
                    onBack: () => _navKey.currentState!.maybePop(),
                    onNext: () => _navKey.currentState!.pushNamed(SendRoutes.stSummary),
                  ),
                ),
              );

            // 4b) STANDARD Summary
            case SendRoutes.stSummary:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => StandardSummaryScreen(
                  formModel: _formModel,
                  onBack: () => _navKey.currentState!.maybePop(),

                  // If SendStandardScreen ends by sending, you can navigate out or push a tiny status.
                  // You can also change this to two routes (stAmount, stSummary) later without touching this controller.
                ),
              );

            default:
              return MaterialPageRoute(builder: (_) => const Center(child: Text('Route not found')));
          }
        },
      ),
    );
  }
}

class _TitleNavObserver extends NavigatorObserver {
  _TitleNavObserver({required this.onTopRouteChange});
  final void Function(String? topRouteName) onTopRouteChange;

  void _emit(Route<dynamic>? route) {
    onTopRouteChange(route?.settings.name);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _emit(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _emit(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _emit(newRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _emit(previousRoute);
  }
}
