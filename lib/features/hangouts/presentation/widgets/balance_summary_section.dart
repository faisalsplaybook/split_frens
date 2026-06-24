import 'package:flutter/material.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../data/models/hangout_model.dart';
import '../../data/models/person_model.dart';
import '../../data/services/split_calculator_service.dart';

// ==========================================
// Balance Summary Section Widget
// ==========================================
// Displays the total spent summary card and individual balance list.
class BalanceSummarySection extends StatelessWidget {
  final double totalSpent;
  final int totalExpenses;
  final Map<String, double> netBalances;
  final List<PersonModel> allPeople;
  final HangoutModel hangout;
  final SplitCalculatorService calculator;

  const BalanceSummarySection({
    super.key,
    required this.totalSpent,
    required this.totalExpenses,
    required this.netBalances,
    required this.allPeople,
    required this.hangout,
    required this.calculator,
  });

  String _getPersonName(String personId) {
    return allPeople
        .firstWhere(
          (p) => p.id == personId,
          orElse: () => PersonModel(id: personId, name: 'Unknown'),
        )
        .name;
  }

  @override
  Widget build(BuildContext context) {
    final convertedTotals = calculator.calculateTotalConverted(hangout);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Spent Card
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
                  MoneyFormatter.format(totalSpent, currencyCode: hangout.defaultCurrency),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (convertedTotals.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...convertedTotals.entries.map((e) => Text(
                    '(${MoneyFormatter.format(e.value, currencyCode: e.key)})',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  )),
                ],
                const SizedBox(height: 8),
                Text(
                  '$totalExpenses Expenses',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Individual Balances
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
            final name = _getPersonName(personId);

            final isPositive = balance >= 0;
            final balanceColor = isPositive ? Colors.green : Colors.red;
            final balanceText = isPositive ? 'Gets back' : 'Owes';

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

            final ratio = totalSpent > 0 ? balance.abs() / totalSpent : 0.0;

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
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyFormatter.format(balance.abs(), currencyCode: hangout.defaultCurrency),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                  if (ratio > 0 && convertedTotals.isNotEmpty)
                     ...convertedTotals.entries.map((e) => Text(
                       MoneyFormatter.format(e.value * ratio, currencyCode: e.key),
                       style: TextStyle(fontSize: 12, color: balanceColor.withValues(alpha: 0.8)),
                     )),
                ],
              ),
            );
          }),
      ],
    );
  }
}
