import 'package:flutter/material.dart';

// ==========================================
// Split Results Screen
// ==========================================
// This shows how much each person owes/is owed after calculations.
class SplitResultsScreen extends StatelessWidget {
  final String hangoutId;

  const SplitResultsScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Results'),
      ),
      body: Center(
        child: Text(
          'We will show the math/results for Hangout: $hangoutId!',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
