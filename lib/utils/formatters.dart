import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:solana/base58.dart';

String formatSol(double value, {int maxDecimals = 6}) {
  if (value == 0) return '0';
  String formatted = value.toStringAsFixed(maxDecimals);

  // Remove trailing zeros and the decimal point if not needed
  formatted = formatted.replaceAll(RegExp(r'0+$'), '');
  formatted = formatted.replaceAll(RegExp(r'\.$'), '');

  return formatted;
}

String shortenPubkey(String pubkey) {
  if (pubkey.length <= 10) return pubkey;
  return '${pubkey.substring(0, 4).toUpperCase()}..${pubkey.substring(pubkey.length - 4).toUpperCase()}';
}

String formatTimeAgo(int unixSeconds) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  final diff = now.difference(date);

  if (diff.inSeconds < 60) {
    return "just now";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago";
  } else {
    // After 24 hours → USA date format like "Jul 14"
    return DateFormat('MMM d').format(date);
  }
}

String formatFullDateTime(int unixSeconds) {
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  // Example: "July 14, 2025 3:45 PM"
  return DateFormat('MMMM d, yyyy h:mm a').format(date);
}

String formatFullDate(int unixSeconds) {
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  // Example: "July 14, 2025"
  return DateFormat('MMMM d, yyyy').format(date);
}

String formatTime(int unixSeconds) {
  final date = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000);
  // Example: "3:45 PM"
  return DateFormat('h:mm a').format(date);
}

DateTime? dateTimeOrNull(int? secondsEpoch) =>
    secondsEpoch == null ? null : DateTime.fromMillisecondsSinceEpoch(secondsEpoch);

//Convert signature for view
String signatureToBase58(Uint8List sigBytes) {
  return base58encode(sigBytes);
}

String formatDelay(int seconds) {
  final minutes = seconds ~/ 60; // integer division
  final leftover = seconds % 60; // remainder
  if (minutes > 0) {
    return leftover > 0 ? "$minutes min ${leftover}s" : "$minutes min";
  } else {
    return "${leftover}s";
  }
}

String formatDurationShort(Duration d) => d.inSeconds < 1
    ? '${d.inMilliseconds} ms'
    : d.inMinutes < 1
    ? '${d.inSeconds}s'
    : '${d.inMinutes}m ${d.inSeconds % 60}s';
