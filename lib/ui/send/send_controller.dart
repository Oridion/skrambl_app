// Dart SDK
import 'dart:async';

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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

// App: UI
import 'package:skrambl_app/ui/send/helpers/status_result.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skr_status_screen.dart';
import 'package:skrambl_app/ui/send/screens/standard/standard_amount_screen.dart';
import 'package:skrambl_app/ui/send/screens/send_type_selection_screen.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skr_amount_screen.dart';
import 'package:skrambl_app/ui/send/screens/send_destination_screen.dart';
import 'package:skrambl_app/ui/send/screens/skrambl/skr_summary_screen.dart';

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
  //SendFormModel _lastAttemptedFormModel = SendFormModel();
  String? _currentDraftId; // Draft db id
  bool _isResend = false; // Controls send button handler
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
    skrLogger.i("Send controller disposed");
    _pageController.dispose();
    super.dispose();
  }

  late final _TitleNavObserver _navObserver = _TitleNavObserver(onTopRouteChange: _setTitleSafely);

  void _setTitleSafely(String? routeName) {
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
      //If from burner, override
      if (widget.fromWalletOverride != null) {
        _formModel.userWallet = widget.fromWalletOverride;
        _formModel.userBurnerIndex = widget.fromBurnerIndexOverride;
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

  // Go to status screen, checking for completion
  Future<SendStatusResult?> _pushStatus({
    required Uint8List txBytes,
    required Uint8List signature,
    required String podPdaBase58,
    required String localId,
    required SendFormModel formModel,
  }) {
    return Navigator.of(context).push<SendStatusResult>(
      MaterialPageRoute(
        builder: (_) => SendStatusScreen(
          localId: localId,
          txBytes: txBytes,
          signature: signature,
          podPDA: Ed25519HDPublicKey.fromBase58(podPdaBase58),
          destination: formModel.destinationWallet!,
          amount: formModel.amount!,
          isDelayed: formModel.isDelayed,
        ),
      ),
    );
  }

  // Handle results back from _pushStatus
  Future<void> _handleStatusResult(SendStatusResult? result) async {
    if (!mounted || result == null) return;
    skrLogger.i("[HANDLE STATUS RESULT] ${result.type}");
    setState(() => _isSubmitting = false);

    switch (result.type) {
      case SendStatusResultType.failed:
        _failedSend(result.message ?? 'Send failed. Please try again.', true);
        break;

      //On cancled transaction, let's delete the draft.
      //We only keep drafts of signed
      case SendStatusResultType.canceled:
        skrLogger.i("CANCELED");
        skrLogger.i(result.localId);
        skrLogger.i(result.message);

        _failedSend(result.message ?? 'Transaction was cancled. Please try again.', true);
        break;
      case SendStatusResultType.submitted:
        break;
    }
  }

  //SEND SKRAMBLED TRANSACTION
  void sendSkrambled() async {
    if (_isSubmitting) return;
    skrLogger.i("SENDING");
    skrLogger.i(_formModel.toString());

    //Store last attempt first thing on send attempt
    setState(() {
      //_lastAttemptedFormModel = _formModel;
      _isSubmitting = true;
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

    //Set passcode to form object
    _formModel.passcode = passcode;

    final payload = LaunchPodRequest(
      id: podId,
      destination: _formModel.destinationWallet!,
      lamports: (_formModel.amount! * lamportsPerSol).floor(),
      userWallet: userWallet.toString(),
      delay: _formModel.delaySeconds,
      passcode: passcode,
      showMemo: 0,
      returnType: "message",
    );
    //skrLogger.i("📦 Payload: $payload");

    // Fetch unsigned tx and attach to db.
    late final String unsignedBase64Tx;
    try {
      unsignedBase64Tx = await fetchUnsignedLaunchTx(payload);
    } catch (e) {
      skrLogger.e('Send failed: $e');
      //Issue with getting signed transaction from API, Since the db draft has not been created
      //yet, Whe show failed without setting to isResend (false)
      _failedSend('There was an issue sending the transaction. Please try to resend.', false);
      return;
    }

    // Derive the Pod PDA
    var podPDA = await getPodPDA(id: podId, creator: userWallet);
    skrLogger.i("POD PDA: ${podPDA.toString()}");

    // Insert draft pod into the database only if successfully received
    // unsigned message from API.
    // Note: `podId` is used as a local identifier, not the on-chain
    // PDA. It should be unique for each pod.
    skrLogger.i("Creating draft pod with ID: $podId");
    final localId = await dao.createDraft(
      creator: userWallet.toString(), // the Seed Vault pubkey
      podId: podId,
      podPda: podPDA.toBase58(),
      lamports: (_formModel.amount! * lamportsPerSol).floor(),
      mode: _formModel.delaySeconds == 0 ? 0 : 1, // 0=instant, 1=delay
      delaySeconds: _formModel.delaySeconds,
      showMemo: false,
      escapeCode: passcode, // optional, for local recovery
      destination: _formModel.destinationWallet!,
      isCreatorBurner: widget.fromBurnerIndexOverride != null,
      isDestinationBurner: _formModel.isDestinationBurner,
      unsignedBase64Tx: unsignedBase64Tx,
    );

    // Set current draft ID
    setState(() => _currentDraftId = localId);

    // Update blockhash before signing
    final txBytes = await setBlockHashOnUnsigneMessage(unsignedBase64Tx);

    // Sign transaction
    late final Uint8List signature;
    try {
      signature = await SeedVaultService.signMessage(
        messageBytes: txBytes,
        authToken: token, // Passing authToken from getValidToken
      );
    } catch (e) {
      _handleStatusResult(SendStatusResult.canceled(localId: localId, message: 'Transaction was canceled.'));
      return;
    }
    skrLogger.i("Signature: $signature");

    final result = await _pushStatus(
      localId: _currentDraftId!,
      txBytes: txBytes,
      signature: signature,
      podPdaBase58: podPDA.toBase58(),
      formModel: _formModel,
    );
    await _handleStatusResult(result);
  }

  // Failed to send
  // Don’t discard the draft; we want to RESEND
  void _failedSend(String message, bool isResend) {
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (isResend) _isResend = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Resend the transaction if it failed
  // We need to update blockhash and re-sign
  Future<void> _resendFromDraft() async {
    skrLogger.i("RESENDING");
    skrLogger.i(_formModel.toString());
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Get POD from db. (Required)
    final dao = context.read<PodDao>();
    final pod = await dao.watchById(_currentDraftId!).first;
    if (pod == null) {
      //This should never come up as pod should always be found if resending.
      _failedSend('Delivery draft was not found. Cannot resend', false);
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
            isDelayed: _formModel.isDelayed,
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
            isDelayed: _formModel.isDelayed,
          ),
        ),
      );
      await _handleStatusResult(result);
      return;
    }

    // Case B: (Only other case) not submitted yet → sign, send
    // Update blockhash before signing
    final txBytes = await setBlockHashOnUnsigneMessage(pod.unsignedMessageB64!);
    if (!mounted) return;
    final token = await SeedVaultService.getValidToken(context);
    if (token == null) {
      _failedSend('Resend failed. Could not get a valid token', true);
      return;
    }

    late final Uint8List signature;
    try {
      signature = await SeedVaultService.signMessage(messageBytes: txBytes, authToken: token);
    } catch (e) {
      if (e != '') skrLogger.e('Resend failed: $e');
      _handleStatusResult(
        SendStatusResult.canceled(localId: _currentDraftId, message: 'Transaction was canceled.'),
      );
    }

    final result = await _pushStatus(
      txBytes: txBytes,
      signature: signature,
      podPdaBase58: pod.podPda!,
      localId: _currentDraftId!,
      formModel: _formModel,
    );
    await _handleStatusResult(result);
  }

  Future<void> _goBack(BuildContext context) async {
    // Dismiss the keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Give the viewInsets a frame to settle
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      _navKey.currentState?.maybePop();
    }
  }

  //When navigating to summary,
  //If _lastAttemptedFormModel is empty, skip. (label stays send)
  //if _lastAttemptedFormModel is set and is equal to _formModel,
  //This should ALWAYS be a resend.
  Future<void> _toSummaryAndCompare() async {
    //Delete previous draft
    //If the current draft id is set then make sure we delete the previous draft.
    if (_currentDraftId != null) {
      skrLogger.i("DELETING OLD DRAFT POD: ");
      final dao = context.read<PodDao>();
      await dao.deleteById(_currentDraftId!);
      setState(() {
        _currentDraftId = null;
        _isResend = false;
      });
    }
    _navKey.currentState!.pushNamed(SendRoutes.skSummary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            await SystemChannels.textInput.invokeMethod('TextInput.hide');

            // Give the viewInsets a frame to settle
            await Future.delayed(const Duration(milliseconds: 180));
            final didPop = await _navKey.currentState?.maybePop() ?? false;
            if (!context.mounted) return;
            if (!didPop) Navigator.of(context).maybePop();
          },
        ),
      ),
      body: Navigator(
        key: _navKey,
        observers: [_navObserver],
        initialRoute: SendRoutes.type,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // 1) choose type (shared)
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
                  builder: (routeCtx) => SendDestinationScreen(
                    formModel: _formModel,
                    onBack: () => _goBack(routeCtx),
                    onNext: () {
                      if (_formModel.isSkrambled == true) {
                        // Skrambled route
                        _navKey.currentState!.pushNamed(SendRoutes.skAmount);
                      } else {
                        // standard route
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
                  onNext: () => _toSummaryAndCompare(),
                ),
              );

            // 4a) SKRAMBL summary
            case SendRoutes.skSummary:
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => SkrambledSummaryScreen(
                  key: ValueKey('summary-$_isResend-${_currentDraftId ?? ""}'),
                  formModel: _formModel,
                  canResend: _isResend,
                  isSubmitting: _isSubmitting,
                  onBack: () => _navKey.currentState!.maybePop(),
                  onSend: _isResend ? _resendFromDraft : sendSkrambled,
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
