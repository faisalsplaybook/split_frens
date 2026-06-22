import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/hangout_model.dart';
import '../../data/services/split_calculator_service.dart';
import '../providers/expense_provider.dart';
import '../providers/hangout_provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';

// ==========================================
// History Screen
// ==========================================
// Shows all saved hangouts. User can open or delete any hangout.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hangouts = ref.watch(hangoutsProvider);
    final allExpenses = ref.watch(expensesProvider);
    final calculator = SplitCalculatorService(allExpenses: allExpenses);

    // Sort by most recent first
    final sorted = [...hangouts]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: sorted.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final hangout = sorted[index];
                return _HangoutHistoryCard(
                  hangout: hangout,
                  calculator: calculator,
                  onOpen: () => context.push('/hangout/${hangout.id}'),
                  onDelete: () => _confirmDelete(context, ref, hangout),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No saved hangouts yet.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a hangout to get started.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    HangoutModel hangout,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Hangout?'),
        content: Text(
          'Are you sure you want to delete "${hangout.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Remove from provider (which auto-saves to Hive)
              ref.read(hangoutsProvider.notifier).deleteHangout(hangout.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${hangout.title}" deleted.'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// History Card Widget
// ==========================================
class _HangoutHistoryCard extends StatelessWidget {
  final HangoutModel hangout;
  final SplitCalculatorService calculator;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _HangoutHistoryCard({
    required this.hangout,
    required this.calculator,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = calculator.calculateTotalSpent(hangout);
    final allSettlements = calculator.generateSettlements(hangout);
    final unpaidCount = allSettlements
        .where((s) => !hangout.paidSettlementIds.contains(s.id))
        .length;
    final isFullySettled = allSettlements.isNotEmpty && unpaidCount == 0;
    final statusLabel = allSettlements.isEmpty
        ? 'No expenses'
        : isFullySettled
            ? 'Settled'
            : 'Unsettled';
    final statusColor = isFullySettled ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name + date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      hangout.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormatter.format(hangout.startDate),
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Middle row: total + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    MoneyFormatter.format(totalAmount),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom row: stats + actions
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 15, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${hangout.participantIds.length} people',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.receipt_long_outlined,
                      size: 15, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${hangout.expenseIds.length} expenses',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const Spacer(),
                  // Delete action
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 22,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
