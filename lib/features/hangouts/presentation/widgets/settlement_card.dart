import 'package:flutter/material.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../data/models/hangout_model.dart';
import '../../data/models/person_model.dart';
import '../../data/models/settlement_model.dart';
import '../../data/services/split_calculator_service.dart';

// ==========================================
// Settlement Card Widget
// ==========================================
// A reusable card that displays a single settlement transaction with
// paid/unpaid styling and a toggle button.
class SettlementCard extends StatelessWidget {
  final SettlementModel settlement;
  final List<PersonModel> allPeople;
  final VoidCallback onTogglePaid;
  final HangoutModel hangout;
  final SplitCalculatorService calculator;
  final double totalSpent;

  const SettlementCard({
    super.key,
    required this.settlement,
    required this.allPeople,
    required this.onTogglePaid,
    required this.hangout,
    required this.calculator,
    required this.totalSpent,
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
    final debtorName = _getPersonName(settlement.payerId);
    final creditorName = _getPersonName(settlement.payeeId);

    final isPaid = settlement.isPaid;
    final cardColor = const Color(0xFF1E293B);
    final textColor = const Color(0xFFF8FAFC);
    final iconColor = isPaid
        ? const Color(0xFF22C55E)
        : const Color(0xFFF59E0B);
    final iconData = isPaid ? Icons.check_circle : Icons.warning_amber_rounded;

    final convertedTotals = calculator.calculateTotalConverted(hangout);
    final ratio = totalSpent > 0 ? settlement.amount / totalSpent : 0.0;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  isPaid ? 'Paid' : 'Unpaid',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      MoneyFormatter.format(
                        settlement.amount,
                        currencyCode: hangout.defaultCurrency,
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
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
                            fontSize: 14,
                            color: Color(0xFF5EEAD4),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(fontSize: 18, color: textColor),
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
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onTogglePaid,
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: textColor.withValues(alpha: 0.5)),
                ),
                child: Text(isPaid ? 'Mark as Unpaid' : 'Mark as Paid'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
