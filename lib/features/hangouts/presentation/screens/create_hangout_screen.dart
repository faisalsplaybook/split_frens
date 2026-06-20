import 'package:flutter/material.dart';

// ==========================================
// Create Hangout Screen
// ==========================================
// This is a StatelessWidget because a placeholder screen doesn't 
// need to manage any complex changing data (state) yet.
class CreateHangoutScreen extends StatelessWidget {
  const CreateHangoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structural framework for a screen.
    // It gives us standard things like an AppBar at the top and a body.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Hangout'),
      ),
      // Center widget aligns its child exactly in the middle of the screen.
      body: const Center(
        child: Text(
          'We will build the Create Hangout form here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
