import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../data/models/person_model.dart';
import '../providers/expense_provider.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';

// ==========================================
// Expense Detail Screen
// ==========================================
class ExpenseDetailScreen extends ConsumerWidget {
  final String hangoutId;
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.hangoutId,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch the expense
    final expense = ref
        .watch(expensesProvider)
        .firstWhere(
          (e) => e.id == expenseId,
          orElse: () => throw Exception('Expense not found'),
        );

    // Fetch the hangout
    final hangout = ref
        .watch(hangoutsProvider)
        .firstWhere(
          (h) => h.id == hangoutId,
          orElse: () => throw Exception('Hangout not found'),
        );

    // 2. Fetch people
    final allPeople = ref.watch(personsProvider);
    final payer = allPeople.firstWhere(
      (p) => p.id == expense.paidById,
      orElse: () => PersonModel(id: expense.paidById, name: 'Unknown'),
    );

    final participants = expense.participantIds
        .map(
          (id) => allPeople.firstWhere(
            (p) => p.id == id,
            orElse: () => PersonModel(id: id, name: 'Unknown'),
          ),
        )
        .toList();

    // 3. Calculate per-person share (Assuming equal split for MVP)
    final shareAmount = participants.isEmpty
        ? 0.0
        : expense.amount / participants.length;

    // Formatting currency
    final formattedAmount = MoneyFormatter.format(
      expense.amount,
      currencyCode: hangout.defaultCurrency,
    );
    final formattedShare = MoneyFormatter.format(
      shareAmount,
      currencyCode: hangout.defaultCurrency,
    );

    final convertedShareAmount =
        expense.convertedAmount != null && participants.isNotEmpty
        ? expense.convertedAmount! / participants.length
        : null;
    final formattedConvertedShare =
        convertedShareAmount != null && expense.currency != null
        ? MoneyFormatter.format(
            convertedShareAmount,
            currencyCode: expense.currency,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFF59E0B)),
            onPressed: () {
              // Deletion isn't implemented yet.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete not implemented yet')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(context, expense, formattedAmount),
          const SizedBox(height: 16),
          _buildPayerAndNote(payer, expense),
          const SizedBox(height: 16),
          _buildParticipantsAndShare(
            context,
            participants,
            formattedShare,
            formattedConvertedShare,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, expense, String formattedAmount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              expense.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              formattedAmount,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (expense.convertedAmount != null) ...[
              const SizedBox(height: 8),
              Text(
                'Converted: ${MoneyFormatter.format(expense.convertedAmount!, currencyCode: expense.currency)}',
                style: const TextStyle(fontSize: 16, color: Color(0xFF5EEAD4)),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Added on ${DateFormatter.format(expense.date)}',
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayerAndNote(PersonModel payer, expense) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paid By',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    payer.name.isNotEmpty ? payer.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  payer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (expense.note != null && expense.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Note',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 4),
              Text(expense.note!, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsAndShare(
    BuildContext context,
    List<PersonModel> participants,
    String formattedShare,
    String? formattedConvertedShare,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'For ${participants.length} Participants',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$formattedShare / person',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (formattedConvertedShare != null)
                      Text(
                        '$formattedConvertedShare / person',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5EEAD4),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...participants.map((person) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  child: Text(
                    person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                title: Text(person.name),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedShare,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (formattedConvertedShare != null)
                      Text(
                        formattedConvertedShare,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5EEAD4),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
