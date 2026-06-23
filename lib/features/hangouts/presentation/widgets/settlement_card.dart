import 'package:flutter/material.dart';

import '../../data/models/person_model.dart';
import '../../data/models/settlement_model.dart';

// ==========================================
// Settlement Card Widget
// ==========================================
// A reusable card that displays a single settlement transaction with
// paid/unpaid styling and a toggle button.
class SettlementCard extends StatelessWidget {
  final SettlementModel settlement;
  final List<PersonModel> allPeople;
  final VoidCallback onTogglePaid;

  const SettlementCard({
    super.key,
    required this.settlement,
    required this.allPeople,
    required this.onTogglePaid,
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
    final cardColor = isPaid
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.errorContainer;
    final textColor = isPaid
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Theme.of(context).colorScheme.onErrorContainer;
    final iconColor = isPaid ? Colors.green : Theme.of(context).colorScheme.error;
    final iconData = isPaid ? Icons.check_circle : Icons.warning_amber_rounded;

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
                Text(
                  '\$${settlement.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(fontSize: 18, color: textColor),
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
                  side: BorderSide(
                    color: textColor.withValues(alpha: 0.5),
                  ),
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
