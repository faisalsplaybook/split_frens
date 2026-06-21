
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hangout_model.dart';
import '../../../../data/dummy_data.dart';

// ==========================================
// Hangouts Notifier (State Management)
// ==========================================
// In Riverpod, a Notifier is a class that holds "State" (data that changes)
// and provides methods to update that state. When the state changes, any UI
// listening to it will automatically rebuild!
//
// Here, our state is simply a List<HangoutModel>.
class HangoutsNotifier extends Notifier<List<HangoutModel>> {
  // 1. Initial State
  @override
  List<HangoutModel> build() {
    // We start by loading our dummy data so the screen isn't empty.
    // When we add Hive (database) later, we will load from Hive here instead!
    return [...DummyData.allHangouts];
  }

  // ==========================================
  // Core Hangout Methods
  // ==========================================

  /// Creates a new hangout and adds it to our state list
  void createHangout(HangoutModel newHangout) {
    // To update state in Riverpod, you MUST create a entirely new list.
    // You cannot do state.add(newHangout).
    // The `...state` syntax takes all existing items, and we append the new one.
    state = [...state, newHangout];
  }

  /// Deletes a hangout by its ID
  void deleteHangout(String id) {
    // .where() filters the list, keeping only the ones that DO NOT match the ID.
    state = state.where((hangout) => hangout.id != id).toList();
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
        // We found the target hangout! Let's update its participants.
        final newParticipants = [...hangout.participantIds, personId];
        return hangout.copyWith(participantIds: newParticipants);
      }
      return hangout; // Return all other hangouts exactly as they were
    }).toList();
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
  }

  /// Marks a specific debt/settlement as Unpaid
  void markSettlementUnpaid(String hangoutId, String settlementId) {
    state = state.map((hangout) {
      if (hangout.id == hangoutId) {
        return hangout.copyWith(
          paidSettlementIds:
              hangout.paidSettlementIds
                  .where((id) => id != settlementId)
                  .toList(),
        );
      }
      return hangout;
    }).toList();
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
