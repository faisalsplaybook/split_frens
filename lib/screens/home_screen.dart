import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

/// The main entry screen of the application.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a Scaffold to get basic Material Design layout structure (like AppBar, Body, FAB).
    return Scaffold(
      appBar: AppBar(
        // The title of the app
        title: const Text(
          'SplitFrens',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ==========================================
            // Tagline
            // ==========================================
            Text(
              'Split trips. Settle fast.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24), // Spacing
            // ==========================================
            // Section Title
            // ==========================================
            const SizedBox(
              width: double.infinity, // Forces the widget to take full width
              child: Text(
                'Your Hangouts',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // ==========================================
            // Dummy Hangout Card
            // ==========================================
            // We use our dummy data to populate the card
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.local_dining),
                ),
                title: Text(
                  DummyData.fridayKacchiNight.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  // Show the number of participants
                  '${DummyData.fridayKacchiNight.participantIds.length} people • ${DummyData.fridayKacchiNight.expenseIds.length} expenses',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // In the future, this will navigate to the hangout details
                },
              ),
            ),
          ],
        ),
      ),
      // ==========================================
      // Create Hangout Button
      // ==========================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Action for creating a new hangout (to be implemented)
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Hangout'),
      ),
    );
  }
}
