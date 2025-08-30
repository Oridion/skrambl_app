import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/ui/root_shell.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/duration.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/utils/solana.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';

class CompletedStatusView extends StatelessWidget {
  final double amountSol;
  final String destination;
  final String signatureBase58;
  final int? durationSec;
  final int? fallbackDurationSec;
  final AnimationController fadeController;

  const CompletedStatusView({
    super.key,
    required this.amountSol,
    required this.destination,
    required this.signatureBase58,
    required this.fadeController,
    this.durationSec,
    this.fallbackDurationSec,
  });

  @override
  Widget build(BuildContext context) {
    final amountStr = '$amountSol SOL';

    return FadeTransition(
      opacity: fadeController.drive(CurveTween(curve: Curves.easeOut)),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 217, 230, 221), Color.fromARGB(255, 211, 225, 214)],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSuccessBadge(),
                      const SizedBox(height: 16),
                      const Text(
                        'Delivered',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your SKRAMBL transfer has finalized.',
                        style: TextStyle(fontSize: 14.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      _buildReceiptCard(context, amountStr),
                      const SizedBox(height: 14),

                      _buildActions(context),
                      const SizedBox(height: 16),
                      const Text(
                        'Balances will refresh shortly after confirmation.',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        height: 92,
        width: 92,
        decoration: BoxDecoration(
          color: Colors.green.withOpacityCompat(0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green.withOpacityCompat(0.25), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.green.withOpacityCompat(0.18), blurRadius: 24, spreadRadius: 1),
          ],
        ),
        child: const Icon(Icons.check_rounded, size: 48, color: Colors.green),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, String amountStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 30, 36, 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacityCompat(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _amountRow(amountStr),
          const SizedBox(height: 20),
          _destinationRow(context),
          const SizedBox(height: 14),
          _signatureRow(context),
          const SizedBox(height: 10),
          _durationRow(),
        ],
      ),
    );
  }

  Widget _amountRow(String amountStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AMOUNT', style: TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(offset: const Offset(2, 8), child: const SolanaLogo(size: 12, useDark: true)),
            const SizedBox(width: 13),
            Text(amountStr, style: const TextStyle(fontSize: 18.5, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }

  Widget _destinationRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DESTINATION', style: TextStyle(fontSize: 13, color: Colors.black54)),
        Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            SelectableText(
              shortenPubkey(destination, length: 8),
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Copy address',
              icon: const Icon(Icons.copy_rounded, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: destination));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Address copied'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(milliseconds: 1200),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _signatureRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SIGNATURE', style: TextStyle(fontSize: 13, color: Colors.black54)),
        Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            SelectableText(
              shortenPubkey(signatureBase58, length: 8),
              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'View on SolanaFM',
              icon: const Icon(Icons.arrow_outward_rounded, size: 18),
              onPressed: () => openOnSolanaFM(context, signatureBase58),
            ),
          ],
        ),
      ],
    );
  }

  Widget _durationRow() {
    final dur = durationSec ?? fallbackDurationSec;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DURATION', style: TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 8),
        if (dur != null)
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                formatDurationReadable(dur),
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.read<WalletProvider>().refresh();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const RootShell(initialIndex: 0)),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
          label: const Text('Done'),
        ),
      ],
    );
  }
}
