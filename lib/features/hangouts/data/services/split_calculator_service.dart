

import '../models/expense_model.dart';
import '../models/hangout_model.dart';
import '../models/settlement_model.dart';

// ==========================================
// Split Calculator Service
// ==========================================
// The core mathematical engine for the app. It calculates who paid what,
// who owes what, and generates the final settlement transactions.
class SplitCalculatorService {
  final List<ExpenseModel> allExpenses;

  SplitCalculatorService({required this.allExpenses});

  /// 1. Calculates the total amount spent across all expenses in a hangout (in base currency)
  double calculateTotalSpent(HangoutModel hangout) {
    double total = 0.0;
    for (final expenseId in hangout.expenseIds) {
      final expense = _getExpense(expenseId);
      if (expense != null) {
        total += expense.amount;
      }
    }
    return total;
  }

  /// Calculates the total converted amounts grouped by currency
  Map<String, double> calculateTotalConverted(HangoutModel hangout) {
    final totals = <String, double>{};
    for (final expenseId in hangout.expenseIds) {
      final expense = _getExpense(expenseId);
      if (expense != null && expense.convertedAmount != null && expense.currency != null) {
        totals[expense.currency!] = (totals[expense.currency!] ?? 0.0) + expense.convertedAmount!;
      }
    }
    return totals;
  }

  /// 2. Calculates how much each person actually paid out of pocket (in base currency)
  Map<String, double> calculatePaidAmounts(HangoutModel hangout) {
    final paidAmounts = <String, double>{};

    // Initialize all participants to 0
    for (final personId in hangout.participantIds) {
      paidAmounts[personId] = 0.0;
    }

    // Add up the amounts paid by each person
    for (final expenseId in hangout.expenseIds) {
      final expense = _getExpense(expenseId);
      if (expense != null &&
          hangout.participantIds.contains(expense.paidById)) {
        paidAmounts[expense.paidById] =
            (paidAmounts[expense.paidById] ?? 0.0) + expense.amount;
      }
    }

    return paidAmounts;
  }

  /// 3. Calculates how much each person SHOULD have paid (their share)
  Map<String, double> calculateShareAmounts(HangoutModel hangout) {
    final shareAmounts = <String, double>{};

    // Initialize all participants to 0
    for (final personId in hangout.participantIds) {
      shareAmounts[personId] = 0.0;
    }

    // Add up the shares for each expense
    for (final expenseId in hangout.expenseIds) {
      final expense = _getExpense(expenseId);
      if (expense != null && expense.participantIds.isNotEmpty) {
        final share = calculatePerPersonShare(expense);

        for (final participantId in expense.participantIds) {
          if (hangout.participantIds.contains(participantId)) {
            shareAmounts[participantId] =
                (shareAmounts[participantId] ?? 0.0) + share;
          }
        }
      }
    }

    return shareAmounts;
  }

  /// 4. Calculates the net balance for each person (Paid - Share)
  /// Positive = they are owed money
  /// Negative = they owe money
  Map<String, double> calculateNetBalances(HangoutModel hangout) {
    final paidAmounts = calculatePaidAmounts(hangout);
    final shareAmounts = calculateShareAmounts(hangout);

    final netBalances = <String, double>{};

    for (final personId in hangout.participantIds) {
      final paid = paidAmounts[personId] ?? 0.0;
      final share = shareAmounts[personId] ?? 0.0;
      netBalances[personId] = paid - share;
    }

    return netBalances;
  }

  /// 5. Generates the minimum number of transactions to settle all debts
  List<SettlementModel> generateSettlements(HangoutModel hangout) {
    final netBalances = calculateNetBalances(hangout);

    // Separate into debtors (owe money) and creditors (are owed money)
    final debtors = <String, double>{};
    final creditors = <String, double>{};

    netBalances.forEach((personId, balance) {
      if (balance < -0.01) {
        debtors[personId] = balance.abs(); // Store as positive amount they owe
      } else if (balance > 0.01) {
        creditors[personId] = balance; // Amount they are owed
      }
    });

    final settlements = <SettlementModel>[];

    // Greedy algorithm: match highest debtor with highest creditor
    while (debtors.isNotEmpty && creditors.isNotEmpty) {
      // Find person who owes the most
      var maxDebtorId = debtors.keys.first;
      for (final id in debtors.keys) {
        if (debtors[id]! > debtors[maxDebtorId]!) {
          maxDebtorId = id;
        }
      }

      // Find person who is owed the most
      var maxCreditorId = creditors.keys.first;
      for (final id in creditors.keys) {
        if (creditors[id]! > creditors[maxCreditorId]!) {
          maxCreditorId = id;
        }
      }

      final debtorAmount = debtors[maxDebtorId]!;
      final creditorAmount = creditors[maxCreditorId]!;

      // Determine the settlement amount (the smaller of the two)
      final settlementAmount = debtorAmount < creditorAmount
          ? debtorAmount
          : creditorAmount;

      // Deterministic ID: ensures if amount changes, the ID changes and resets paid status
      final settlementId =
          '${hangout.id}_${maxDebtorId}_${maxCreditorId}_${settlementAmount.toStringAsFixed(2)}';

      // Create the settlement
      settlements.add(
        SettlementModel(
          id: settlementId,
          payerId: maxDebtorId,
          payeeId: maxCreditorId,
          amount: settlementAmount,
          date: DateTime.now(),
          isPaid: hangout.paidSettlementIds.contains(settlementId),
        ),
      );

      // Update remaining balances
      debtors[maxDebtorId] = debtorAmount - settlementAmount;
      creditors[maxCreditorId] = creditorAmount - settlementAmount;

      // Remove if resolved (using a small threshold for floating point math)
      if (debtors[maxDebtorId]! < 0.01) debtors.remove(maxDebtorId);
      if (creditors[maxCreditorId]! < 0.01) creditors.remove(maxCreditorId);
    }

    return settlements;
  }

  /// 6. Helper to calculate a single expense's per-person share (in base currency)
  double calculatePerPersonShare(ExpenseModel expense) {
    if (expense.participantIds.isEmpty) return 0.0;
    return expense.amount / expense.participantIds.length;
  }

  // Helper to safely get an expense
  ExpenseModel? _getExpense(String id) {
    try {
      return allExpenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
