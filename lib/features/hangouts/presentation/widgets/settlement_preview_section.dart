import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/summary_generator.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/hangout_model.dart';
import '../../data/models/person_model.dart';
import '../../data/models/settlement_model.dart';

// ==========================================
// Settlement Preview Section Widget
// ==========================================
// Displays the "How to Settle Up" section with settlement cards
// and a Share Final Split button.
class SettlementPreviewSection extends StatelessWidget {
  final HangoutModel hangout;
  final List<SettlementModel> settlements;
  final List<PersonModel> allPeople;
  final List<ExpenseModel> allExpenses;
  final double totalSpent;

  const SettlementPreviewSection({
    super.key,
    required this.hangout,
    required this.settlements,
    required this.allPeople,
    required this.allExpenses,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            final debtorName = _getPersonName(settlement.payerId);
            final creditorName = _getPersonName(settlement.payeeId);

            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.compare_arrows, color: Colors.grey),
                ),
                title: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(fontSize: 16),
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

        // Share Final Split button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: OutlinedButton.icon(
            onPressed: () {
              if (hangout.expenseIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add expenses before sharing a summary.'),
                  ),
                );
                return;
              }

              final hangoutPeople = allPeople
                  .where((p) => hangout.participantIds.contains(p.id))
                  .toList();
              final hangoutExpenses = allExpenses
                  .where((e) => hangout.expenseIds.contains(e.id))
                  .toList();

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
      ],
    );
  }
}
