import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import '../../data/models/hangout_model.dart';
import '../../data/models/person_model.dart';
import '../providers/expense_provider.dart';
import '../../data/services/split_calculator_service.dart';

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
    // 1. Get the lists of data
    final hangouts = ref.watch(hangoutsProvider);
    final allExpenses = ref.watch(expensesProvider);
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

    // Calculate Summary Data
    final calculator = SplitCalculatorService(allExpenses: allExpenses);
    final totalSpent = calculator.calculateTotalSpent(hangout);
    final settlements = calculator.generateSettlements(hangout);
    final unpaidCount = settlements.where((s) => !s.isPaid).length;

    final summaryStatusText = unpaidCount == 0 
        ? 'Everyone settled' 
        : '$unpaidCount unpaid settlement${unpaidCount > 1 ? 's' : ''}';

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

          const SizedBox(height: 24),

          // ==========================================
          // Summary Card
          // ==========================================
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hangout Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Expense:'),
                      Text('\$${totalSpent.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('People Count:'),
                      Text('${hangout.participantIds.length}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Expense Count:'),
                      Text('${hangout.expenseIds.length}'),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(
                        unpaidCount == 0 ? Icons.check_circle : Icons.warning_amber_rounded,
                        color: unpaidCount == 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        summaryStatusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: unpaidCount == 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ==========================================
          // People Preview
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Participants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${hangout.participantIds.length} people',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (hangout.participantIds.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, color: Colors.grey),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Add friends to start splitting.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push('/hangout/$hangoutId/add-people'),
                      child: const Text('Add Now'),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hangout.participantIds.length,
                itemBuilder: (context, index) {
                  final personId = hangout!.participantIds[index];
                  // In a real app we might fetch the PersonModel to show initials
                  // But since we have access to personsProvider, let's get it!
                  final allPeople = ref.read(personsProvider);
                  final person = allPeople.firstWhere(
                    (p) => p.id == personId,
                    // Fallback just in case
                    orElse: () => PersonModel(id: personId, name: '?'),
                  );

                  final initials = person.name.isNotEmpty
                      ? person.name.substring(0, 1).toUpperCase()
                      : '?';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
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

          Builder(
            builder: (context) {
              final allExpenses = ref.watch(expensesProvider);
              final hangoutExpenses = allExpenses
                  .where((e) => hangout!.expenseIds.contains(e.id))
                  .toList();

              if (hangoutExpenses.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No expenses added yet.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hangoutExpenses.length,
                itemBuilder: (context, index) {
                  final expense = hangoutExpenses[index];

                  // Get Payer Name safely
                  final allPeople = ref.read(personsProvider);
                  final payer = allPeople.firstWhere(
                    (p) => p.id == expense.paidById,
                    orElse: () =>
                        PersonModel(id: expense.paidById, name: 'Unknown'),
                  );

                  // Currency prefix (fallback to \$ if none)
                  final currencySymbol = expense.currency ?? '\$';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        child: const Icon(Icons.receipt),
                      ),
                      title: Text(expense.title),
                      subtitle: Text(
                        'Paid by ${payer.name} • ${expense.participantIds.length} participants',
                      ),
                      trailing: Text(
                        '$currencySymbol${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        context.push(
                          '/hangout/$hangoutId/expense/${expense.id}',
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
