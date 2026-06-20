import 'package:flutter/material.dart';
import '../features/hangouts/presentation/widgets/hangout_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/hangouts/presentation/providers/hangout_provider.dart';

/// The main entry screen of the application.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the hangouts provider. If the list changes (e.g. a new one is added),
    // this entire HomeScreen will automatically redraw!
    final hangouts = ref.watch(hangoutsProvider);
    return Scaffold(
      appBar: AppBar(
        // App name
        title: const Text(
          'SplitFrens',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Settings icon on the top right
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the Settings screen
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The Expanded widget makes this section take up all available space
            // pushing the buttons at the bottom down.
            Expanded(
              child: hangouts.isEmpty
                  ? _buildEmptyState(context)
                  : _buildRecentHangouts(context, hangouts),
            ),

            // ==========================================
            // Call to Actions (CTAs) at the bottom
            // ==========================================
            const SizedBox(height: 16),

            // Primary CTA
            SizedBox(
              width: double.infinity, // Make the button take full width
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the Create Hangout screen
                  context.push('/create-hangout');
                },
                child: const Text('Create Hangout'),
              ),
            ),

            const SizedBox(height: 12),

            // Secondary CTA
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to the History screen
                  context.push('/history');
                },
                child: const Text('View History'),
              ),
            ),
            const SizedBox(height: 16), // A little padding at the very bottom
          ],
        ),
      ),
    );
  }

  /// Builds the view shown when there are NO hangouts
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No hangouts yet.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first hangout.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// Builds the view shown when there ARE recent hangouts
  Widget _buildRecentHangouts(BuildContext context, List<dynamic> hangouts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Text(
          'Your Hangouts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // List of hangout cards
        // We use ListView.builder for scrollable lists
        Expanded(
          child: ListView.builder(
            itemCount: hangouts.length,
            itemBuilder: (context, index) {
              final hangout = hangouts[index];
              return HangoutCard(hangout: hangout);
            },
          ),
        ),
      ],
    );
  }
}
