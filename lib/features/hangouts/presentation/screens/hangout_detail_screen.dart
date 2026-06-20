import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hangout_provider.dart';
import '../../../../models/hangout_model.dart';

// ==========================================
// Hangout Detail Screen
// ==========================================
// This is the main hub for a specific hangout. From here, you can add people,
// add expenses, view results, and see settlements.
class HangoutDetailScreen extends ConsumerWidget {
  final String hangoutId;

  const HangoutDetailScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the list of all hangouts from our Riverpod provider
    final hangouts = ref.watch(hangoutsProvider);

    // 2. Try to find the specific hangout for this screen
    // We use a simple loop or firstWhere to find it safely
    HangoutModel? hangout;
    try {
      hangout = hangouts.firstWhere((h) => h.id == hangoutId);
    } catch (e) {
      hangout = null; // firstWhere throws an error if no match is found
    }

    // 3. Error State (If the hangout doesn't exist)
    if (hangout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Hangout not found.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Normal State (If the hangout exists)
    return Scaffold(
      appBar: AppBar(
        // We use the actual title of the hangout instead of the raw ID!
        title: Text(hangout.title),
        actions: [
          // Share Summary Action
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share placeholder for now!')),
              );
            },
          ),
        ],
      ),
      // We use a ListView so the screen can scroll if we have many expenses
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ==========================================
          // 1. Core Action Buttons
          // ==========================================
          Wrap(
            spacing: 8, // Space between buttons horizontally
            runSpacing: 8, // Space between buttons vertically if they wrap
            children: [
              ElevatedButton.icon(
                onPressed: () => context.push('/hangout/$hangoutId/add-people'),
                icon: const Icon(Icons.person_add),
                label: const Text('Add People'),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    context.push('/hangout/$hangoutId/add-expense'),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Add Expense'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/hangout/$hangoutId/results'),
                icon: const Icon(Icons.pie_chart),
                label: const Text('Split Results'),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/hangout/$hangoutId/settlements'),
                icon: const Icon(Icons.handshake),
                label: const Text('Settlements'),
              ),
              // Currency Converter (Usually shown if travel mode is enabled)
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/hangout/$hangoutId/currency-converter'),
                icon: const Icon(Icons.currency_exchange),
                label: const Text('Currency Converter'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ==========================================
          // 2. Expenses List
          // ==========================================
          const Text(
            'Recent Expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // A placeholder dummy expense tile to demonstrate navigation
          // to the Expense Detail Screen.
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.fastfood)),
              title: const Text('Dinner at Luigi\'s'),
              subtitle: const Text('Paid by Alice'),
              trailing: const Text(
                '\$45.00',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onTap: () {
                // Navigate to a specific expense inside this hangout.
                // We hardcode the expenseId 'exp_123' for this dummy tile.
                context.push('/hangout/$hangoutId/expense/exp_123');
              },
            ),
          ),
        ],
      ),
    );
  }
}
