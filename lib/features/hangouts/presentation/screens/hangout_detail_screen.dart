import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import '../../data/models/hangout_model.dart';
import '../providers/expense_provider.dart';
import '../../data/services/split_calculator_service.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/summary_generator.dart';
import '../widgets/summary_section.dart';
import '../widgets/people_section.dart';
import '../widgets/expense_section.dart';

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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
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

    return Scaffold(
      appBar: AppBar(
        // We use the actual title of the hangout instead of the raw ID!
        title: Text(hangout.title),
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
              OutlinedButton.icon(
                onPressed: () {
                  if (hangout!.expenseIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add expenses before sharing a summary.'),
                      ),
                    );
                    return;
                  }

                  final allPeople = ref.read(personsProvider);
                  final hangoutPeople = allPeople
                      .where((p) => hangout!.participantIds.contains(p.id))
                      .toList();
                  final hangoutExpenses = allExpenses
                      .where((e) => hangout!.expenseIds.contains(e.id))
                      .toList();

                  final summary = SummaryGenerator.generateSummary(
                    hangout: hangout,
                    expenses: hangoutExpenses,
                    people: hangoutPeople,
                    settlements: settlements,
                    totalExpense: totalSpent,
                    calculator: calculator,
                  );

                  // ignore: deprecated_member_use
                  Share.share(summary);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Summary'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==========================================
          // 2. Summary Card (Extracted Widget)
          // ==========================================
          SummarySection(hangout: hangout),

          const SizedBox(height: 24),

          // ==========================================
          // 3. People Preview (Extracted Widget)
          // ==========================================
          PeopleSection(hangout: hangout),

          const SizedBox(height: 32),

          // ==========================================
          // 4. Expenses List (Extracted Widget)
          // ==========================================
          ExpenseSection(hangout: hangout),
        ],
      ),
    );
  }
}
