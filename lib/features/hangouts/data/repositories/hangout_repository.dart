import '../models/hangout_model.dart';
import '../services/local_storage_service.dart';
import '../models/person_model.dart';
import '../models/expense_model.dart';

// ==========================================
// Hangout Repository
// ==========================================
// This acts as a clean bridge between our providers and the actual storage logic.
class HangoutRepository {
  Future<List<HangoutModel>> getHangouts() async {
    return LocalStorageService.loadHangouts();
  }

  // To preserve our relational data architecture, saving must save all lists.
  // The provider will pass the current state of all three lists.
  Future<void> saveHangouts({
    required List<HangoutModel> hangouts,
    required List<PersonModel> persons,
    required List<ExpenseModel> expenses,
  }) async {
    await LocalStorageService.saveAllData(
      hangouts: hangouts,
      persons: persons,
      expenses: expenses,
    );
  }

  Future<void> deleteHangout(
    String id, {
    required List<HangoutModel> currentHangouts,
    required List<PersonModel> currentPersons,
    required List<ExpenseModel> currentExpenses,
  }) async {
    final updatedHangouts = currentHangouts.where((h) => h.id != id).toList();
    await saveHangouts(
      hangouts: updatedHangouts,
      persons: currentPersons,
      expenses: currentExpenses,
    );
  }

  Future<void> clearAll() async {
    await LocalStorageService.clearAllData();
  }
}
