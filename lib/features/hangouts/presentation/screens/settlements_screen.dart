import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/person_model.dart';
import '../../data/services/split_calculator_service.dart';
import '../providers/expense_provider.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/summary_generator.dart';
// ==========================================
// Settlements Screen
// ==========================================
class SettlementsScreen extends ConsumerWidget {
  final String hangoutId;

  const SettlementsScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch data
    final hangout = ref.watch(hangoutsProvider).firstWhere(
          (h) => h.id == hangoutId,
          orElse: () => throw Exception('Hangout not found'),
        );
    final allExpenses = ref.watch(expensesProvider);
    final allPeople = ref.watch(personsProvider);

    // 2. Initialize Calculator & Generate Settlements
    final calculator = SplitCalculatorService(allExpenses: allExpenses);
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

    // Helper for "Share" functionality
    void shareSettlements() {
      if (settlements.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nothing to share! Everyone is settled.')),
        );
        return;
      }

      final hangoutPeople = allPeople.where((p) => hangout.participantIds.contains(p.id)).toList();
      final hangoutExpenses = allExpenses.where((e) => hangout.expenseIds.contains(e.id)).toList();
      final totalSpent = calculator.calculateTotalSpent(hangout);

      final summary = SummaryGenerator.generateSummary(
        hangout: hangout,
        expenses: hangoutExpenses,
        people: hangoutPeople,
        settlements: settlements,
        totalExpense: totalSpent,
      );

      // ignore: deprecated_member_use
      Share.share(summary);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settlements'),
        actions: const [],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: shareSettlements,
                icon: const Icon(Icons.share),
                label: const Text('Share Settlement Summary'),
              ),
            ),
          ),
          Expanded(
            child: settlements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Everyone is settled.',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: settlements.length,
              itemBuilder: (context, index) {
                final settlement = settlements[index];
                final debtorName = getPersonName(settlement.payerId);
                final creditorName = getPersonName(settlement.payeeId);

                // Visual Distinction
                final isPaid = settlement.isPaid;
                final cardColor = isPaid ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.errorContainer;
                final textColor = isPaid ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onErrorContainer;
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
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 18,
                                  color: textColor,
                                ),
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
                            onPressed: () {
                              final notifier = ref.read(hangoutsProvider.notifier);
                              if (isPaid) {
                                notifier.markSettlementUnpaid(hangoutId, settlement.id);
                              } else {
                                notifier.markSettlementPaid(hangoutId, settlement.id);
                              }
                            },
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
