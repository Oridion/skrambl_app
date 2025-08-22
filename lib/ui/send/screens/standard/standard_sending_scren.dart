import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/skrambl_dao.dart';
import 'package:skrambl_app/models/send_form_model.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/solana/solana_client_service.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:skrambl_app/utils/solana.dart';
import 'package:solana/solana.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class StandardSendingScreen extends StatefulWidget {
  final SendFormModel form;
  const StandardSendingScreen({super.key, required this.form});

  @override
  State<StandardSendingScreen> createState() => _StandardSendingScreenState();
}

class _StandardSendingScreenState extends State<StandardSendingScreen> {
  static const int lamportsPerSol = 1000000000;

  String _phase = 'Preparing…';
  String? _signature; // tx sig when submitted
  String? _error;
  bool _done = false; // confirmed (or failed if _error != null)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    // ---------- Phase 0: Seed Vault availability + token ----------
    setState(() => _phase = 'Requesting Seed Vault permission…');

    final bool svAvailable;
    try {
      svAvailable = await SeedVault.instance.isAvailable(allowSimulated: true);
    } catch (e, st) {
      skrLogger.e('Seed Vault availability check failed: $e\n$st');
      setState(() {
        _error = 'Seed Vault check failed.';
        _done = true;
      });
      return;
    }
    if (!svAvailable) {
      setState(() {
        _error = 'Seed Vault not available';
        _done = true;
      });
      return;
    }

    final authToken = await SeedVaultService.getValidToken(context);
    if (authToken == null) {
      setState(() {
        _error = 'Seed Vault permission denied';
        _done = true;
      });
      return;
    }

    // ---------- Phase 1: Resolve sender (primary vs burner) ----------
    setState(() => _phase = 'Resolving wallet…');

    final int? burnerIdx = widget.form.userBurnerIndex;
    late final Ed25519HDPublicKey sender;
    Uri? resolvedBurnerPath;

    try {
      if (burnerIdx == null) {
        final pk = await SeedVaultService.getPublicKey(authToken: authToken);
        if (pk == null) throw Exception('Failed to get public key');
        sender = pk;
      } else {
        resolvedBurnerPath = await SeedVaultService.resolvePathForIndex(
          index: burnerIdx,
          purpose: Purpose.signSolanaTransaction,
        );
        final exposed = await SeedVaultService.exposeAndGetPubkeyAtIndex(
          authToken: authToken,
          index: burnerIdx,
        );
        sender = Ed25519HDPublicKey.fromBase58(exposed);
      }
    } catch (e, st) {
      skrLogger.e('Resolve wallet failed: $e\n$st');
      setState(() {
        _error = 'Could not resolve wallet.';
        _done = true;
      });
      return;
    }

    skrLogger.i(sender.toBase58());
    skrLogger.i(widget.form.toString());

    // ---------- Phase 2: Build message ----------
    setState(() => _phase = 'Building transaction…');

    final RpcClient rpc = SolanaClientService().rpcClient;
    final Ed25519HDPublicKey dest = Ed25519HDPublicKey.fromBase58(widget.form.destinationWallet!);
    final int lamports = (widget.form.amount! * lamportsPerSol).floor();
    final blockhash = (await rpc.getLatestBlockhash()).value.blockhash;

    skrLogger.i("LAMPORTS: $lamports");

    //TESTING
    final feeLamports = await estimateFeeForTransfer(
      from: sender,
      to: dest,
      lamports: lamports,
      recentBlockhash: blockhash,
    );
    skrLogger.i("fee: $feeLamports");

    late Uint8List messageBytes;
    try {
      messageBytes = await _buildSystemTransferSignable(
        recentBlockhash: blockhash,
        from: sender,
        to: dest,
        lamports: lamports,
      );
    } catch (e, st) {
      skrLogger.e('Build message failed: $e\n$st');
      setState(() {
        _error = 'Failed to build transaction.';
        _done = true;
      });
      return;
    }

    // ---------- Phase 3: Sign ----------
    setState(() => _phase = 'Awaiting signature…');

    late Uint8List signature;
    try {
      if (resolvedBurnerPath == null) {
        // Primary
        signature = await SeedVaultService.signMessage(messageBytes: messageBytes, authToken: authToken);
      } else {
        // Burner with explicit path
        signature = await SeedVaultService.signMessageWithResolvedPath(
          authToken: authToken,
          messageBytes: messageBytes,
          resolvedPath: resolvedBurnerPath,
        );
      }
      if (signature.length != 64) throw Exception('Invalid signature length');
    } on PlatformException catch (e, st) {
      // Handle user-cancel or platform error distinctly
      final canceled = e.code == 'ActionFailedException' && (e.message?.contains('result=0') ?? false);
      if (canceled) {
        skrLogger.i('User canceled signature.');
        setState(() {
          _error = 'Signature request canceled.';
          _done = true;
        });
        return;
      }
      skrLogger.e('Signing PlatformException: $e\n$st');
      setState(() {
        _error = 'Signing failed.';
        _done = true;
      });
      return;
    } catch (e, st) {
      skrLogger.e('Signing failed: $e\n$st');
      setState(() {
        _error = 'Signing failed.';
        _done = true;
      });
      return;
    }

    // ---------- Phase 4: Submit ----------
    setState(() => _phase = 'Submitting…');

    late String txSig;
    try {
      txSig = await _sendSignedTransaction(rpc: rpc, messageBytes: messageBytes, signature: signature);

      // Persist "pending" record
      try {
        final dao = context.read<PodDao>();
        await dao.upsertStandardPendingBySig(
          signature: txSig,
          creator: sender.toBase58(),
          destination: widget.form.destinationWallet!,
          lamports: lamports,
        );
      } catch (e) {
        skrLogger.w('DB upsert (standard pending) failed: $e');
      }
      setState(() {
        _signature = txSig;
      });
    } catch (e, st) {
      skrLogger.e('Submit failed: $e\n$st');
      if (!mounted) return;
      final dao = context.read<PodDao>();
      // Not submitted yet → nothing to mark failed by sig
      setState(() {
        _error = 'Failed to submit transaction.';
        _done = true;
      });
      return;
    }

    // ---------- Phase 5: Confirm ----------
    setState(() => _phase = 'Confirming…');

    try {
      await _confirmSignature(rpc, txSig);
    } catch (e, st) {
      // Not fatal; we still show submitted with sig
      skrLogger.w('Confirmation timed out or failed: $e\n$st');
    }

    // ---------- Phase 6: DB finalize (+ mark burner used if applicable) ----------
    if (!mounted) return;
    try {
      final dao = context.read<PodDao>();
      await dao.markStandardFinalizedBySig(txSig);
    } catch (e) {
      skrLogger.w('DB finalize (standard) failed: $e');
    }

    if (burnerIdx != null && mounted) {
      try {
        final burnerDao = context.read<BurnerDao>();
        await burnerDao.markUsed(pubkey: sender.toBase58());
      } catch (e) {
        skrLogger.w('Failed to mark burner used: $e');
      }
    }

    // ---------- Done ----------
    setState(() {
      _phase = 'Confirmed';
      _done = true;
    });
  }

  Future<Uint8List> _buildSystemTransferSignable({
    required String recentBlockhash,
    required Ed25519HDPublicKey from,
    required Ed25519HDPublicKey to,
    required int lamports,
  }) async {
    final transferIx = SystemInstruction.transfer(
      fundingAccount: from,
      recipientAccount: to,
      lamports: lamports,
    );
    final msg = Message(instructions: [transferIx]);
    final compiled = msg.compile(recentBlockhash: recentBlockhash, feePayer: from);
    return Uint8List.fromList(compiled.toByteArray().toList());
  }

  Uint8List _encodeShortVecLength(int n) {
    final out = <int>[];
    var v = n;
    while (true) {
      var elem = v & 0x7F;
      v >>= 7;
      if (v == 0) {
        out.add(elem);
        break;
      } else {
        out.add(elem | 0x80);
      }
    }
    return Uint8List.fromList(out);
  }

  Future<String> _sendSignedTransaction({
    required RpcClient rpc,
    required Uint8List messageBytes,
    required Uint8List signature,
  }) async {
    try {
      return await _sendWire(rpc, messageBytes, signature);
    } catch (e) {
      final msg = e.toString();
      final expired = msg.contains('BlockhashNotFound') || msg.contains('blockhash not found');
      if (!expired) rethrow;

      // refresh blockhash and resign once
      if (!mounted) throw Exception('Unmounted during blockhash refresh');
      final authToken = await SeedVaultService.getValidToken(context);
      if (authToken == null) throw Exception('Seed Vault permission denied');

      final recent = await rpc.getLatestBlockhash();
      final sender = await SeedVaultService.getPublicKey(authToken: authToken);
      final dest = Ed25519HDPublicKey.fromBase58(widget.form.destinationWallet!);
      final lamports = (widget.form.amount! * lamportsPerSol).floor();

      final freshMsg = await _buildSystemTransferSignable(
        recentBlockhash: recent.value.blockhash,
        from: sender!,
        to: dest,
        lamports: lamports,
      );
      final freshSig = await SeedVaultService.signMessage(
        messageBytes: freshMsg,
        authToken: (await SeedVaultService.getValidToken(context))!,
      );
      return _sendWire(rpc, freshMsg, freshSig);
    }
  }

  Future<String> _sendWire(RpcClient rpc, Uint8List msg, Uint8List sig) async {
    if (sig.length != 64) throw Exception('Invalid signature length: ${sig.length}');
    final sigCount = _encodeShortVecLength(1);
    final wire = Uint8List(sigCount.length + sig.length + msg.length)
      ..setRange(0, sigCount.length, sigCount)
      ..setRange(sigCount.length, sigCount.length + sig.length, sig)
      ..setRange(sigCount.length + sig.length, sigCount.length + sig.length + msg.length, msg);
    final b64 = base64Encode(wire);
    return rpc.sendTransaction(b64);
  }

  Future<void> _confirmSignature(RpcClient rpc, String sig) async {
    var delay = const Duration(milliseconds: 600);
    for (int i = 0; i < 12; i++) {
      try {
        final res = await rpc.getSignatureStatuses([sig], searchTransactionHistory: true);
        final st = res.value.first;
        if (st != null) {
          final cs = st.confirmationStatus; // Commitment enum in this sdk
          if (cs == Commitment.finalized || cs == Commitment.confirmed) return;
        }
      } catch (_) {}
      await Future.delayed(delay);
      if (delay.inMilliseconds < 4000) delay *= 2;
    }
    // If we time out, we still show "Submitted" with the sig & explorer link.
  }

  // ---------- UI helpers ----------
  String _short(String s, {int head = 6, int tail = 6}) =>
      s.length <= head + tail + 1 ? s : '${s.substring(0, head)}…${s.substring(s.length - tail)}';

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied'), duration: const Duration(milliseconds: 1200)));
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _done && _error == null;
    final isError = _done && _error != null;

    return Scaffold(
      body: Container(
        color: isSuccess ? Colors.green.withOpacityCompat(0.1) : Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSuccess
                      ? _buildSuccessView()
                      : (isError ? _buildErrorView() : _buildProgressView()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressView() {
    return Column(
      key: const ValueKey('progress'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.flash_on, size: 56, color: Colors.black87),
        const SizedBox(height: 14),
        Text(_phase, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        const CircularProgressIndicator(),
        if (_signature != null) ...[
          const SizedBox(height: 18),
          SelectableText(
            'Signature: $_signature',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => openOnSolanaFM(context, _signature!),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('View on Solscan'),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessView() {
    final amt = widget.form.amount ?? 0;
    final dest = widget.form.destinationWallet ?? '';
    final user = widget.form.userWallet ?? ''; // set earlier in your flow

    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // check badge
        Container(
          height: 92,
          width: 92,
          decoration: BoxDecoration(
            color: Colors.green.withOpacityCompat(.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.withOpacityCompat(.25), width: 2),
            // boxShadow: [
            //   BoxShadow(color: Colors.green.withOpacityCompat(.18), blurRadius: 24, spreadRadius: 1),
            // ],
          ),
          child: const Icon(Icons.check_rounded, size: 48, color: Colors.green),
        ),
        const SizedBox(height: 14),
        const Text('Sent', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text(
          'Your transfer has been confirmed.',
          style: TextStyle(fontSize: 14.5, color: Colors.black54),
        ),
        const SizedBox(height: 24),

        // receipt card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacityCompat(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
            boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // amount
              Row(
                children: [
                  const Icon(Icons.send_rounded, size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
                  const Text('Amount', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                  const Spacer(),
                  Text('$amt SOL', style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // from → to diagram
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // left (from)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('From', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                        const SizedBox(height: 6),
                        SelectableText(
                          user.isEmpty ? '—' : _short(user),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  // arrow + amount
                  Column(
                    children: [
                      const SizedBox(height: 4),
                      const Icon(Icons.south_rounded, size: 22, color: Colors.black54),
                      const SizedBox(height: 6),
                      Text('$amt SOL', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // right (to)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('To', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                        const SizedBox(height: 6),
                        SelectableText(
                          dest.isEmpty ? '—' : _short(dest),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // signature row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Signature', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                  const Spacer(),
                  if (_signature != null)
                    TextButton.icon(
                      onPressed: () => _copy(_signature!, 'Signature'),
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text(_short(_signature!)),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // actions
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _signature == null ? null : () => openOnSolanaFM(context, _signature!),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black26),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('View on SolanaFM'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          key: const ValueKey('error'),
          constraints: BoxConstraints(maxHeight: constraints.maxHeight, maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Color(0xFFB3261E)),
              const SizedBox(height: 14),
              const Text('Failed to send', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),

              // Make the long text scrollable
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(_error ?? 'Unknown error', style: const TextStyle(fontSize: 13)),
                ),
              ),

              const SizedBox(height: 12),
              if (_signature != null)
                TextButton.icon(
                  onPressed: () => openOnSolanaFM(context, _signature!),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View on SolanaFM'),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: const Text('Back'),
              ),
            ],
          ),
        );
      },
    );
  }
}
