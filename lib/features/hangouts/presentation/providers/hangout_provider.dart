import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hangout_model.dart';
import '../../data/services/local_storage_service.dart';
import 'person_provider.dart';
import 'expense_provider.dart';

// ==========================================
// Hangouts Notifier (State Management)
// ==========================================
class HangoutsNotifier extends Notifier<List<HangoutModel>> {
  @override
  List<HangoutModel> build() {
    return LocalStorageService.loadHangouts();
  }

  void _save() {
    // Because we need to save all 3 lists at once to maintain normalized integrity
    LocalStorageService.saveAllData(
      hangouts: state,
      persons: ref.read(personsProvider),
      expenses: ref.read(expensesProvider),
    );
  }

  // ==========================================
  // Core Hangout Methods
  // ==========================================

  /// Creates a new hangout and adds it to our state list
  void createHangout(HangoutModel newHangout) {
    state = [...state, newHangout];
    _save();
  }

  /// Deletes a hangout by its ID
  void deleteHangout(String id) {
    state = state.where((hangout) => hangout.id != id).toList();
    _save();
  }

  /// Retrieves a specific hangout by its ID
  HangoutModel? getHangoutById(String id) {
    // .firstWhere() finds the first match. If it doesn't find one, it returns null.
    try {
      return state.firstWhere((hangout) => hangout.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Wipes all hangouts from the state
  void clearAllHangouts() {
    state = [];
    _save();
  }

  // ==========================================
  // Modifying Specific Hangouts (Participants & Expenses)
  // ==========================================
  // To update a single hangout inside the list, we have to map over the list,
  // find the correct one, use .copyWith() to update its properties,
  // and leave the others unchanged.

  /// Adds a person to a specific hangout
  void addPerson(String hangoutId, String personId) {
    state = state.map((hangout) {
      if (hangout.id == hangoutId) {
        final newParticipants = [...hangout.participantIds, personId];
        return hangout.copyWith(participantIds: newParticipants);
      }
      return hangout;
    }).toList();
    _save();
  }

  /// Removes a person from a specific hangout
  void removePerson(String hangoutId, String personId) {
    state = state.map((hangout) {
      if (hangout.id == hangoutId) {
        final newParticipants = hangout.participantIds
            .where((id) => id != personId)
            .toList();
        return hangout.copyWith(participantIds: newParticipants);
      }
      return hangout;
    }).toList();
    _save();
  }

  /// Adds an expense to a specific hangout
  void addExpense(String hangoutId, String expenseId) {
    state = state.map((hangout) {
      if (hangout.id == hangoutId) {
        final newExpenses = [...hangout.expenseIds, expenseId];
        return hangout.copyWith(expenseIds: newExpenses);
      }
      return hangout;
    }).toList();
    _save();
  }

  /// Removes an expense from a specific hangout
  void deleteExpense(String hangoutId, String expenseId) {
    state = state.map((hangout) {
      if (hangout.id == hangoutId) {
        final newExpenses = hangout.expenseIds
            .where((id) => id != expenseId)
            .toList();
        return hangout.copyWith(expenseIds: newExpenses);
      }
      return hangout;
    }).toList();
    _save();
  }

  // ==========================================
  // Settlements (Placeholders for future models)
  // ==========================================

  /// Marks a specific debt/settlement as Paid
  void markSettlementPaid(String hangoutId, String settlementId) {
    state = state.map((hangout) {
      if (hangout.id == hangoutId) {
        if (!hangout.paidSettlementIds.contains(settlementId)) {
          return hangout.copyWith(
            paidSettlementIds: [...hangout.paidSettlementIds, settlementId],
          );
        }
      }
      return hangout;
    }).toList();
    _save();
  }

  /// Marks a specific debt/settlement as Unpaid
  void markSettlementUnpaid(String hangoutId, String settlementId) {
    state = state.map((hangout) {
      if (hangout.id == hangoutId) {
        return hangout.copyWith(
          paidSettlementIds: hangout.paidSettlementIds
              .where((id) => id != settlementId)
              .toList(),
        );
      }
      return hangout;
    }).toList();
    _save();
  }
}

// ==========================================
// 2. Defining the Provider
// ==========================================
// We expose our Notifier to the rest of the app using a NotifierProvider.
// Any widget can read or watch this provider to get the current list of hangouts!
final hangoutsProvider = NotifierProvider<HangoutsNotifier, List<HangoutModel>>(
  () {
    return HangoutsNotifier();
  },
);
