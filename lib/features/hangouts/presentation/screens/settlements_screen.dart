import 'package:flutter/material.dart';

// ==========================================
// Settlements Screen
// ==========================================
// This shows exactly WHO needs to pay WHOM (e.g., Alice pays Bob $10).
class SettlementsScreen extends StatelessWidget {
  final String hangoutId;

  const SettlementsScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlements'),
      ),
      body: Center(
        child: Text(
          'We will show payment instructions for Hangout: $hangoutId!',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
