import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hangout_model.dart';
import '../../data/services/split_calculator_service.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/expense_provider.dart';
import 'package:go_router/go_router.dart';

/// A custom widget to display the summary of a Hangout.
class HangoutCard extends ConsumerWidget {
  final HangoutModel hangout;

  const HangoutCard({super.key, required this.hangout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpenses = ref.watch(expensesProvider);
    final calculator = SplitCalculatorService(allExpenses: allExpenses);
    final totalAmount = calculator.calculateTotalSpent(hangout);

    final String dateStr = DateFormatter.format(hangout.startDate);
    final String totalAmountStr = MoneyFormatter.format(totalAmount, currencyCode: hangout.defaultCurrency);

    // Determine settlement status based on the hangout's paidSettlementIds
    // We can't run the full settlement calc here without a circular dependency,
    // so we check if any settlements exist by seeing if the hangout has expenses.
    // A simple heuristic: if all settlement IDs are paid, it's settled.
    // For now we just show Settled vs Unsettled.
    final allSettlements = calculator.generateSettlements(hangout);
    final unpaidCount = allSettlements
        .where((s) => !hangout.paidSettlementIds.contains(s.id))
        .length;
    final isFullySettled = allSettlements.isNotEmpty && unpaidCount == 0;
    final settlementStatusStr = isFullySettled ? 'Settled' : 'Unsettled';
    final settlementColor = isFullySettled ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/hangout/${hangout.id}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // Top Row: Title and Date
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hangout.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ==========================================
              // Middle Row: Total Amount and Status Badge
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        totalAmountStr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: settlementColor.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      settlementStatusStr,
                      style: TextStyle(
                        color: settlementColor.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ==========================================
              // Bottom Row: People and Expenses count
              // ==========================================
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${hangout.participantIds.length} people',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${hangout.expenseIds.length} expenses',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
