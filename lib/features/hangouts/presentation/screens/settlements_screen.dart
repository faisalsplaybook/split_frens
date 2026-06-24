import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_frens/features/hangouts/data/models/hangout_model.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/summary_generator.dart';
import '../../data/services/split_calculator_service.dart';
import '../providers/expense_provider.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import '../widgets/settlement_card.dart';

// ==========================================
// Settlements Screen
// ==========================================
class SettlementsScreen extends ConsumerWidget {
  final String hangoutId;

  const SettlementsScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch data
    final hangout = ref
        .watch(hangoutsProvider)
        .firstWhere(
          (h) => h.id == hangoutId,
          orElse: () => HangoutModel(
            id: '',
            title: '',
            participantIds: [],
            expenseIds: [],
            startDate: DateTime.now(),
          ),
        );

    if (hangout.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Hangout not found.')),
      );
    }

    final allExpenses = ref.watch(expensesProvider);
    final allPeople = ref.watch(personsProvider);

    // 2. Initialize Calculator & Generate Settlements
    final calculator = SplitCalculatorService(allExpenses: allExpenses);
    final settlements = calculator.generateSettlements(hangout);

    // Helper for "Share" functionality
    void shareSettlements() {
      if (settlements.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nothing to share! Everyone is settled.'),
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
      final totalSpent = calculator.calculateTotalSpent(hangout);

      final summary = SummaryGenerator.generateSummary(
        hangout: hangout,
        expenses: hangoutExpenses,
        people: hangoutPeople,
        settlements: settlements,
        totalExpense: totalSpent,
        calculator: calculator,
      );

      // ignore: deprecated_member_use
      Share.share(summary);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settlements')),
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
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: const Color(0xFF22C55E),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Everyone is settled.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: settlements.length,
                    itemBuilder: (context, index) {
                      final settlement = settlements[index];
                      final isPaid = settlement.isPaid;

                      return SettlementCard(
                        settlement: settlement,
                        allPeople: allPeople,
                        hangout: hangout,
                        calculator: calculator,
                        totalSpent: calculator.calculateTotalSpent(hangout),
                        onTogglePaid: () {
                          final notifier =
                              ref.read(hangoutsProvider.notifier);
                          if (isPaid) {
                            notifier.markSettlementUnpaid(
                              hangoutId,
                              settlement.id,
                            );
                          } else {
                            notifier.markSettlementPaid(
                              hangoutId,
                              settlement.id,
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
