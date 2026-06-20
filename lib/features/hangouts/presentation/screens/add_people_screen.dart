import 'package:flutter/material.dart';

// ==========================================
// Add People Screen
// ==========================================
// Used to add friends/participants to a specific hangout.
class AddPeopleScreen extends StatelessWidget {
  final String hangoutId;

  const AddPeopleScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add People'),
      ),
      body: Center(
        child: Text(
          'We will build the Add People form for Hangout: $hangoutId!',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
