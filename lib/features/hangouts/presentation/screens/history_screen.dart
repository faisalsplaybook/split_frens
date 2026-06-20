import 'package:flutter/material.dart';

// ==========================================
// History Screen
// ==========================================
// This shows a list of all past hangouts. It doesn't need an ID parameter
// because it's a global list, not tied to one specific hangout.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: const Center(
        child: Text(
          'We will list all your past hangouts here!',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
