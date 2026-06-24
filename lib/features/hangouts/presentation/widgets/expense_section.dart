import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../data/models/hangout_model.dart';
import '../../data/models/person_model.dart';
import '../providers/expense_provider.dart';
import '../providers/person_provider.dart';

// ==========================================
// Expense Section Widget
// ==========================================
// Displays the "Recent Expenses" header and a list of expense cards,
// or an empty state if no expenses have been added.
class ExpenseSection extends ConsumerWidget {
  final HangoutModel hangout;

  const ExpenseSection({super.key, required this.hangout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expensesProvider);
    final allPeople = ref.watch(personsProvider);
    final hangoutExpenses = allExpenses
        .where((e) => hangout.expenseIds.contains(e.id))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Expenses',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (hangoutExpenses.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No expenses added yet.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hangoutExpenses.length,
            itemBuilder: (context, index) {
              final expense = hangoutExpenses[index];

              // Get Payer Name safely
              final payer = allPeople.firstWhere(
                (p) => p.id == expense.paidById,
                orElse: () =>
                    PersonModel(id: expense.paidById, name: 'Unknown'),
              );

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
                    MoneyFormatter.format(
                      expense.amount,
                      currencyCode: hangout.defaultCurrency,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    context.push(
                      '/hangout/${hangout.id}/expense/${expense.id}',
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
