import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_frens/features/hangouts/data/models/hangout_model.dart';

import '../../data/services/split_calculator_service.dart';
import '../providers/expense_provider.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import '../widgets/balance_summary_section.dart';
import '../widgets/settlement_preview_section.dart';

// ==========================================
// Split Result Screen
// ==========================================
class SplitResultsScreen extends ConsumerWidget {
  final String hangoutId;

  const SplitResultsScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Initialize our service
    final calculator = SplitCalculatorService(allExpenses: allExpenses);

    // Calculate data
    final totalSpent = calculator.calculateTotalSpent(hangout);
    final totalExpenses = hangout.expenseIds.length;
    final netBalances = calculator.calculateNetBalances(hangout);
    final settlements = calculator.generateSettlements(hangout);

    return Scaffold(
      appBar: AppBar(title: const Text('Split Results')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          BalanceSummarySection(
            totalSpent: totalSpent,
            totalExpenses: totalExpenses,
            netBalances: netBalances,
            allPeople: allPeople,
            hangout: hangout,
            calculator: calculator,
          ),

          const SizedBox(height: 32),

          SettlementPreviewSection(
            hangout: hangout,
            settlements: settlements,
            allPeople: allPeople,
            allExpenses: allExpenses,
            totalSpent: totalSpent,
            calculator: calculator,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
