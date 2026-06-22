import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/local_storage_service.dart';
import 'hangout_provider.dart';
import 'person_provider.dart';

class ExpensesNotifier extends Notifier<List<ExpenseModel>> {
  @override
  List<ExpenseModel> build() {
    return LocalStorageService.loadExpenses();
  }

  void _save() {
    LocalStorageService.saveAllData(
      hangouts: ref.read(hangoutsProvider),
      persons: ref.read(personsProvider),
      expenses: state,
    );
  }

  /// Adds a new expense to our global list
  void addExpense(ExpenseModel expense) {
    state = [...state, expense];
    _save();
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
    _save();
  }

  /// Removes an expense completely from the app
  void deleteExpense(String id) {
    state = state.where((e) => e.id != id).toList();
    _save();
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, List<ExpenseModel>>(() {
  return ExpensesNotifier();
});
