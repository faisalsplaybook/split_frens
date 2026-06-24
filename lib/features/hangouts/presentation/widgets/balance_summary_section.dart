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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Total Spent',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  MoneyFormatter.format(
                    totalSpent,
                    currencyCode: hangout.defaultCurrency,
                  ),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (convertedTotals.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...convertedTotals.entries.map(
                    (e) => Text(
                      'Converted: ${MoneyFormatter.format(e.value, currencyCode: e.key)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5EEAD4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  '$totalExpenses Expenses',
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                  textAlign: TextAlign.center,
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
            final balanceColor = isPositive
                ? const Color(0xFF22C55E)
                : const Color(0xFFF59E0B);
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
                  style: TextStyle(color: Color(0xFF94A3B8)),
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
                    MoneyFormatter.format(
                      balance.abs(),
                      currencyCode: hangout.defaultCurrency,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                  if (ratio > 0 && convertedTotals.isNotEmpty)
                    ...convertedTotals.entries.map(
                      (e) => Text(
                        MoneyFormatter.format(
                          e.value * ratio,
                          currencyCode: e.key,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5EEAD4),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
