// For UI-friendly mapped objects

import 'package:intl/intl.dart';

class SkramblModel {
  final int id; // Unique passcode / deposit id
  final String note; // Short user-defined label
  final int status; // 'pending' | 'completed'
  final DateTime createdAt; // When the comet was created
  final String destination; // Destination address

  SkramblModel({
    required this.id,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.destination,
  });

  /// Helper to show a friendly label
  String get statusLabel {
    switch (status) {
      case 2:
        return 'Failed';
      case 1:
        return 'Completed';
      case 0:
      default:
        return 'Pending';
    }
  }

  /// Helper to format created date nicely (e.g. 'Jul 22, 3:41 PM')
  String get formattedCreatedDate {
    final formatter = DateFormat('MMM d, h:mm a');
    return formatter.format(createdAt);
  }
}
