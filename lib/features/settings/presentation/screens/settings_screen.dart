import 'package:flutter/material.dart';

// ==========================================
// Settings Screen
// ==========================================
// Global app settings (like default currency, dark mode, etc).
// Note: This is inside the 'settings' feature folder.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text(
          'We will put app settings here!',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
