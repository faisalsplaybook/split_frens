import 'package:flutter/material.dart';

// ==========================================
// Expense Detail Screen
// ==========================================
// This screen needs TWO parameters because an expense always
// belongs to a specific hangout!
class ExpenseDetailScreen extends StatelessWidget {
  final String hangoutId;
  final String expenseId;

  const ExpenseDetailScreen({
    super.key,
    required this.hangoutId,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Details')),
      body: Center(
        child: Text(
          'Details for Expense: $expenseId\nin Hangout: $hangoutId',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
