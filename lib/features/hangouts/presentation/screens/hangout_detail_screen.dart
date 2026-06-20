import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ==========================================
// Hangout Detail Screen
// ==========================================
// This is the main hub for a specific hangout. From here, you can add people,
// add expenses, view results, and see settlements.
class HangoutDetailScreen extends StatelessWidget {
  final String hangoutId;

  const HangoutDetailScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hangout: $hangoutId'),
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
