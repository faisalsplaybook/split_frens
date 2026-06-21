import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../../../data/dummy_data.dart';

// ==========================================
// Expenses Notifier (State Management)
// ==========================================
// This provider manages all expenses across the entire app.
class ExpensesNotifier extends Notifier<List<ExpenseModel>> {
  @override
  List<ExpenseModel> build() {
    // Start with our dummy data
    return [...DummyData.allExpenses];
  }

  /// Adds a new expense to our global list
  void addExpense(ExpenseModel expense) {
    state = [...state, expense];
  }

  /// Finds an expense by its ID
  ExpenseModel? getExpenseById(String id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing expense
  void updateExpense(ExpenseModel updatedExpense) {
    state = state.map((e) {
      if (e.id == updatedExpense.id) {
        return updatedExpense;
      }
      return e;
    }).toList();
  }

  /// Removes an expense completely from the app
  void deleteExpense(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, List<ExpenseModel>>(() {
  return ExpensesNotifier();
});
