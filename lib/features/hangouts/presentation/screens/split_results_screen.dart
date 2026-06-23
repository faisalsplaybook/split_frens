import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/person_model.dart';
import '../../data/services/split_calculator_service.dart';
import '../providers/expense_provider.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/summary_generator.dart';
// ==========================================
// Split Result Screen
// ==========================================
class SplitResultsScreen extends ConsumerWidget {
  final String hangoutId;

  const SplitResultsScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hangout = ref
        .watch(hangoutsProvider)
        .firstWhere(
          (h) => h.id == hangoutId,
          orElse: () => throw Exception('Hangout not found'),
        );
    final allExpenses = ref.watch(expensesProvider);
    final allPeople = ref.watch(personsProvider);

    // Initialize our service
    final calculator = SplitCalculatorService(allExpenses: allExpenses);

    // 1. Total Spent & Expenses Count
    final totalSpent = calculator.calculateTotalSpent(hangout);
    final totalExpenses = hangout.expenseIds.length;

    // 2. Net Balances
    final netBalances = calculator.calculateNetBalances(hangout);

    // 3. Settlements (Who owes whom)
    final settlements = calculator.generateSettlements(hangout);

    // Helper to get person name safely
    String getPersonName(String personId) {
      return allPeople
          .firstWhere(
            (p) => p.id == personId,
            orElse: () => PersonModel(id: personId, name: 'Unknown'),
          )
          .name;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Split Results')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ==========================================
          // Summary Card
          // ==========================================
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Total Spent',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalSpent.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalExpenses Expenses',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // Person-wise Balances
          // ==========================================
          const Text(
            'Individual Balances',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (netBalances.isEmpty)
            const Text('No balances to show yet.')
          else
            ...netBalances.entries.map((entry) {
              final personId = entry.key;
              final balance = entry.value;
              final name = getPersonName(personId);

              // Positive means they are owed money (gets back)
              // Negative means they owe money (pays)
              final isPositive = balance >= 0;
              final balanceColor = isPositive ? Colors.green : Colors.red;
              final balanceText = isPositive ? 'Gets back' : 'Owes';

              // If balance is practically 0
              if (balance.abs() < 0.01) {
                return ListTile(
                  leading: CircleAvatar(child: Text(name[0].toUpperCase())),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Text(
                    'Settled Up',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListTile(
                leading: CircleAvatar(child: Text(name[0].toUpperCase())),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  balanceText,
                  style: TextStyle(
                    color: balanceColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  '\$${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
              );
            }),

          const SizedBox(height: 32),

          // ==========================================
          // Settlements (Who owes whom)
          // ==========================================
          const Text(
            'How to Settle Up',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (settlements.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'Everyone is settled up!',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ),
              ),
            )
          else
            ...settlements.map((settlement) {
              final debtorName = getPersonName(settlement.payerId);
              final creditorName = getPersonName(settlement.payeeId);

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.compare_arrows, color: Colors.grey),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(
                        context,
                      ).style.copyWith(fontSize: 16),
                      children: [
                        TextSpan(
                          text: debtorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' owes '),
                        TextSpan(
                          text: creditorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  trailing: Text(
                    '\$${settlement.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                final hangoutPeople = allPeople.where((p) => hangout.participantIds.contains(p.id)).toList();
                final hangoutExpenses = allExpenses.where((e) => hangout.expenseIds.contains(e.id)).toList();
                
                final summary = SummaryGenerator.generateSummary(
                  hangout: hangout,
                  expenses: hangoutExpenses,
                  people: hangoutPeople,
                  settlements: settlements,
                  totalExpense: totalSpent,
                );
                
                // ignore: deprecated_member_use
                Share.share(summary);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Final Split'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
