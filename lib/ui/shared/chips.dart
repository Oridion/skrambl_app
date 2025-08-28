// lib/ui/shared/filter_chip_small.dart
import 'package:flutter/material.dart';
import 'package:skrambl_app/ui/shared/solana_logo.dart';
import 'package:skrambl_app/utils/formatters.dart';

class FilterChipSmall extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const FilterChipSmall({super.key, required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: selected ? Colors.black : Colors.grey.shade400, width: 1),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
    );
  }
}

class MonoChip extends StatelessWidget {
  final String text;
  const MonoChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class SolMonoChip extends StatelessWidget {
  final String text;
  const SolMonoChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(0, 1), // x, y — move up 2px
            child: SolanaLogo(size: 8, useDark: true),
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class DelayChip extends StatelessWidget {
  final String text;
  const DelayChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class AmountChip extends StatelessWidget {
  final double sol;
  final String? usd;

  const AmountChip({super.key, required this.sol, this.usd});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasUsd = (usd != null && usd!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SolanaLogo(size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            formatSol(sol),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          if (hasUsd) ...[
            const SizedBox(width: 8),
            Text('•', style: t.bodySmall?.copyWith(color: Colors.white70)),
            const SizedBox(width: 8),
            Text('$usd', style: t.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ],
      ),
    );
  }
}
