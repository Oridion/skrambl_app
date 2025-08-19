import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skrambl_app/constants/app.dart';
import 'package:skrambl_app/utils/colors.dart';
import 'package:skrambl_app/utils/formatters.dart';

class FromToBar extends StatelessWidget {
  final String from;
  final String to;
  final bool isSenderBurner;
  final bool isDestinationBurner;
  final EdgeInsets padding;
  const FromToBar({
    super.key,
    required this.from,
    required this.to,
    required this.isSenderBurner,
    required this.isDestinationBurner,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final valueStyle = const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700);
    final burnerStyle = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: AppConstants.burnerColor,
    );

    Widget copyChip(String text) => InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: text));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address copied'), duration: Duration(milliseconds: 900)),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(6), // small tap target without growing row height
        child: const Icon(Icons.copy_rounded, size: 14, color: Colors.black54),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // FROM
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FROM', style: TextStyle(fontSize: 11, color: Colors.black54, letterSpacing: .6)),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (isSenderBurner)
                    Icon(Icons.local_fire_department, color: AppConstants.burnerColor, size: 18),

                  Expanded(
                    child: Text(
                      shortenPubkey(from),
                      style: isSenderBurner ? burnerStyle : valueStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ARROW
        Transform.translate(
          offset: const Offset(0, 10), // x = horizontal, y = vertical
          child: Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.black.withOpacityCompat(0.65)),
        ),

        // TO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('TO', style: TextStyle(fontSize: 11, color: Colors.black54, letterSpacing: .6)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  copyChip(to),
                  if (isDestinationBurner)
                    Icon(Icons.local_fire_department, color: AppConstants.burnerColor, size: 18),

                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      shortenPubkey(to),
                      style: isDestinationBurner ? burnerStyle : valueStyle,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
