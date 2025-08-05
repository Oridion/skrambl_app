import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/api/launch_pod_service.dart';
import 'package:skrambl_app/models/launch_pod_request.dart';
import 'package:skrambl_app/providers/transaction_status_provider.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/solana/pod_tx_helper.dart';
import 'package:skrambl_app/solana/send_skrambled_transaction.dart';
import 'package:skrambl_app/ui/send/screens/send_status_screen.dart';
import 'package:skrambl_app/utils/launcher.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';
import 'screens/send_type_selection_screen.dart';
import 'screens/send_standard_screen.dart';
import 'screens/skrambled_destination_screen.dart';
import 'screens/skrambled_amount_screen.dart';
import 'screens/skrambled_summary_screen.dart';
import 'send_form_model.dart';

class SendFlowScreen extends StatefulWidget {
  final AuthToken authToken;
  const SendFlowScreen({super.key, required this.authToken});

  @override
  State<SendFlowScreen> createState() => _SendFlowScreenState();
}

class _SendFlowScreenState extends State<SendFlowScreen> {
  final PageController _pageController = PageController();
  final SendFormModel _formModel = SendFormModel();

  int _currentPage = 0;

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

  void sendSkrambled() async {
    final isAvailable = await SeedVault.instance.isAvailable(
      allowSimulated: true,
    );
    if (!isAvailable) {
      throw Exception("Seed Vault not available");
    }

    // 1️⃣ Ask the user to grant SKRAMBL permission to use Seed Vault
    final permissionGranted = await SeedVaultService.requestPermission();
    if (!permissionGranted) {
      skrLogger.e("❌ Seed Vault permission denied.");
      return;
    }

    // 2️⃣ Get a valid AuthToken (either reuse or prompt the authorizeSeed dialog)
    final token = await SeedVaultService.getValidToken(context);
    if (token == null) {
      skrLogger.e("❌ Seed Vault authorization denied.");
      return;
    }

    // 3️⃣ Now derive the public key with that token
    final userWallet = await SeedVaultService.getPublicKey(
      authToken: token, // ← use `token`, not `widget.authToken`
    );
    if (userWallet == null) {
      skrLogger.e("❌ Failed to fetch public key.");
      return;
    }

    // 4️⃣ Build your payload
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
      showMemo: 1,
      returnType: "message",
    );

    var podPDA = await getPodPDA(id: podId, creator: userWallet);
    //skrLogger.i("📦 Payload: $payload");
    skrLogger.i("POD PDA: ${podPDA.toString()}");

    final statusProvider = Provider.of<TransactionStatusProvider>(
      context,
      listen: false,
    );

    try {
      // 5️⃣ Fetch the unsigned tx
      final unsignedBase64Tx = await fetchUnsignedLaunchTx(payload);
      var txBytes = base64Decode(unsignedBase64Tx);

      skrLogger.i("first 64 bytes of txBytes: ${txBytes.sublist(0, 64)}");

      // 🔄 Patch blockhash to ensure it's fresh
      txBytes = await updateBlockhashInMessage(txBytes);

      // 6️⃣ Sign *that* message with your token
      final signature = await SeedVaultService.signMessage(
        messageBytes: txBytes,
        authToken: token, // Passing authToken from getValidToken
      );
      assert(signature.length == 64, "Signature must be 64 bytes");
      skrLogger.i("✅ Signature: $signature");

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SendStatusScreen(
            destination: _formModel.destinationWallet!,
            amount: _formModel.amount!,
            podPDA: podPDA,
          ),
        ),
      );

      //Send transaction and wait for confirmation.
      final txSig = await sendTransactionWithRetry(txBytes, signature, 5, (
        phase,
      ) {
        switch (phase) {
          case TransactionPhase.sending:
            statusProvider.setPhase(TransactionPhase.sending);
            break;
          case TransactionPhase.confirming:
            statusProvider.setPhase(TransactionPhase.confirming);
            break;
          case TransactionPhase.failed:
            statusProvider.setPhase(TransactionPhase.failed);
            break;
          default:
            break;
        }
      });

      //Once we get the tx signature, generate Pod PDA and post api to queue for full travel.
      final queued = await queueInstantPod(
        QueueInstantPodRequest(pod: podPDA.toBase58(), signature: txSig),
      );
      if (queued) {
        // Notify scrambling phase
        statusProvider.setPhase(TransactionPhase.scrambling);
        //skrLogger.i(queued);
        skrLogger.i("POD LAUNCH SEQUENCE COMPLETED SUCCESSFULLY!");
      }
    } catch (e) {
      skrLogger.e("❌ Error from Lambda or signing: $e");
    }
  }

  List<Widget> get _pages {
    // Always start with type selection
    final pages = <Widget>[
      SendTypeSelectionScreen(onNext: nextPage, formModel: _formModel),
    ];

    if (_formModel.isSkrambled == true) {
      pages.addAll([
        SkrambledDestinationScreen(
          onNext: nextPage,
          onBack: prevPage,
          formModel: _formModel,
        ),
        SkrambledAmountScreen(
          onNext: nextPage,
          onBack: prevPage,
          formModel: _formModel,
        ),
        SkrambledSummaryScreen(
          onSend: sendSkrambled,
          onBack: prevPage,
          formModel: _formModel,
        ),
      ]);
    } else {
      pages.add(SendStandardScreen(onBack: prevPage, formModel: _formModel));
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send'),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: prevPage,
              )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }
}
