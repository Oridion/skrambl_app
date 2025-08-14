import 'package:flutter/material.dart';
import '../../data/skrambl_entity.dart';

Color statusColor(PodStatus status) {
  switch (status) {
    case PodStatus.drafting:
      return Colors.grey;
    case PodStatus.launching:
      return Colors.blueGrey;
    case PodStatus.submitted:
      return Colors.blue;
    case PodStatus.scrambling:
      return Colors.deepPurple;
    case PodStatus.delivering:
      return Colors.orange;
    case PodStatus.finalized:
      return Colors.green;
    case PodStatus.failed:
      return Colors.red;
  }
}
