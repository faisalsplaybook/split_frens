import 'package:flutter/material.dart';

// ==========================================
// Add Expenses Screen
// ==========================================
// Used to log a new expense/receipt inside a specific hangout.
class AddExpensesScreen extends StatelessWidget {
  final String hangoutId;

  const AddExpensesScreen({super.key, required this.hangoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Center(
        child: Text(
          'We will build the Add Expense form for Hangout: $hangoutId!',
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
