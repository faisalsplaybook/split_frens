import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/hangout_model.dart';
import '../../data/services/split_calculator_service.dart';
import '../providers/expense_provider.dart';

// ==========================================
// Summary Section Widget
// ==========================================
// Displays the hangout summary card with total expense, people count,
// expense count, and settlement status.
class SummarySection extends ConsumerWidget {
  final HangoutModel hangout;

  const SummarySection({super.key, required this.hangout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expensesProvider);
    final calculator = SplitCalculatorService(allExpenses: allExpenses);
    final totalSpent = calculator.calculateTotalSpent(hangout);
    final settlements = calculator.generateSettlements(hangout);
    final unpaidCount = settlements.where((s) => !s.isPaid).length;

    final summaryStatusText = unpaidCount == 0
        ? 'Everyone settled'
        : '$unpaidCount unpaid settlement${unpaidCount > 1 ? 's' : ''}';

    return Card(
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
                Text(
                  '\$${totalSpent.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
                  unpaidCount == 0
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
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
    );
  }
}
