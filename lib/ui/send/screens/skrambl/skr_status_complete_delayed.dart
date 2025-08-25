import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:skrambl_app/ui/root_shell.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';
import 'package:skrambl_app/providers/wallet_provider.dart';

class CompleteDelayedView extends StatefulWidget {
  final Pod pod;

  const CompleteDelayedView({super.key, required this.pod});

  @override
  State<CompleteDelayedView> createState() => _CompleteDelayedViewState();
}

class _CompleteDelayedViewState extends State<CompleteDelayedView> {
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  late final DateTime _createdAt = _resolveCreatedAt(widget.pod);
  late final int _delaySec = widget.pod.delaySeconds;
  late final DateTime _eta = _createdAt.add(Duration(seconds: _delaySec));

  @override
  void initState() {
    super.initState();
    _tick(); // set initial remaining
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    final now = DateTime.now();
    setState(() => _remaining = _eta.difference(now));
  }

  @override
  Widget build(BuildContext context) {
    final amountSol = _amountSol(widget.pod);
    final destination = widget.pod.destination;
    final etaText = _formatDateTime(_eta);
    final countdown = _formatCountdown(_remaining);

    //skrLogger.i('Submited at: ${widget.pod.submittedAt}');

    final deliveryText = widget.pod.isDestinationBurner
        ? 'Your delivery of ${formatSol(amountSol)} SOL to your burner wallet ${shortenPubkey(destination, length: 4)} '
              'has been successfully scheduled to be delivered around $etaText.'
        : 'Your delivery of ${formatSol(amountSol)} SOL to ${shortenPubkey(destination, length: 4)} '
              'has been successfully scheduled to be delivered around $etaText.';

    return Scaffold(
      body: Stack(
        children: [
          // Soft background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 231, 234, 241), Color.fromARGB(255, 246, 247, 250)],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge
                      Container(
                        height: 92,
                        width: 92,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacityCompat(0.10),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueGrey.withOpacityCompat(0.24), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacityCompat(0.14),
                              blurRadius: 22,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.schedule_rounded, size: 48, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Delivery Scheduled',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          deliveryText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.35),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Countdown chip
                      _CountdownPill(countdown: countdown, isLate: _remaining.isNegative),

                      const SizedBox(height: 24),

                      // Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacityCompat(0.55),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black54, width: 1.2),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.payments_rounded,
                              label: 'Amount',
                              value: '${formatSol(amountSol)} SOL',
                              leading: const SolanaLogo(size: 9, useDark: true),
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Destination',
                              value: shortenPubkey(destination, length: 6),
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              icon: Icons.event_available_rounded,
                              label: 'Estimated delivery',
                              value: etaText,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Help text
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'You can close this screen and view updates anytime from the Pods → Delivery Details page.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Colors.black54),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // OutlinedButton(
                          //   onPressed: () => Navigator.of(context).maybePop(),
                          //   style: OutlinedButton.styleFrom(
                          //     foregroundColor: Colors.black,
                          //     side: const BorderSide(color: Colors.black54, width: 1.2),
                          //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
                          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          //   ),
                          //   child: const Text('Close'),
                          // ),
                          const SizedBox(width: 10),
                          ElevatedButton(
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
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 26),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Go to Dashboard'),
                          ),
                        ],
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

  // --- helpers ---

  static DateTime _resolveCreatedAt(Pod pod) {
    // Try explicit timestamps first; fall back to "now" if absent
    // Adjust the field names to your schema.
    final seconds = pod.submittedAt;
    if (seconds != null && seconds > 0) {
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true).toLocal();
    }
    return DateTime.now();
  }

  static double _amountSol(Pod pod) {
    return pod.lamports / AppConstants.lamportsPerSol;
  }

  static String _formatDateTime(DateTime dt) {
    // Simple, locale-friendly default; replace with intl if you want
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final month = _month(dt.month);
    return '$month ${dt.day}, ${dt.year} • $h:$m $ampm';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _formatCountdown(Duration d) {
    if (d.isNegative) return 'any minute';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$h:$m:$s';
    return '$m:${_two(s)}';
  }

  static String _month(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (m >= 1 && m <= 12) ? names[m - 1] : '—';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? leading;

  const _InfoRow({required this.icon, required this.label, required this.value, this.leading});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: t.bodySmall?.copyWith(color: Colors.black54)),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Padding(padding: const EdgeInsets.only(top: 2), child: leading),
              const SizedBox(width: 6),
            ],
            Text(
              value,
              textAlign: TextAlign.right,
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountdownPill extends StatelessWidget {
  final String countdown;
  final bool isLate;

  const _CountdownPill({required this.countdown, required this.isLate});

  @override
  Widget build(BuildContext context) {
    final bg = isLate ? Colors.orange.withOpacityCompat(0.15) : Colors.black.withOpacityCompat(0.08);

    final fg = isLate ? Colors.orange.shade800 : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacityCompat(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timelapse_rounded, size: 16, color: fg),
          const SizedBox(width: 8),
          Text(
            'Countdown: $countdown',
            style: TextStyle(fontWeight: FontWeight.w700, color: fg, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
