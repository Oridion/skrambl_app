import 'package:flutter/material.dart';
import '../../../models/send_form_model.dart';

class SendStandardScreen extends StatelessWidget {
  final VoidCallback onBack;
  final SendFormModel formModel;

  const SendStandardScreen({
    super.key,
    required this.onBack,
    required this.formModel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Standard Send Form — coming soon'));
  }
}
