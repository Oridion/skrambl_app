// lib/ui/burners/burners_screen.dart
import 'package:flutter/material.dart';

class BurnersScreen extends StatelessWidget {
  const BurnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Burners')),
      body: const Center(child: Text('No burners yet. Tap + to create one.')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: navigate to "New Burner" flow
        },
        icon: const Icon(Icons.add),
        label: const Text('New Burner'),
      ),
    );
  }
}
