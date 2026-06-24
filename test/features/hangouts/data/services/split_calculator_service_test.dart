import 'package:flutter_test/flutter_test.dart';
import 'package:split_frens/features/hangouts/data/models/expense_model.dart';
import 'package:split_frens/features/hangouts/data/models/hangout_model.dart';
import 'package:split_frens/features/hangouts/data/models/split_type.dart';
import 'package:split_frens/features/hangouts/data/services/split_calculator_service.dart';

void main() {
  group('1. Unit tests for split calculation', () {
    test('Equal split among 3 people', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Dinner',
        amount: 300,
        paidById: 'p1',
        participantIds: ['p1', 'p2', 'p3'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2', 'p3'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final balances = service.calculateNetBalances(hangout);

      // p1 paid 300, share 100 -> gets back 200
      // p2 paid 0, share 100 -> owes 100
      // p3 paid 0, share 100 -> owes 100
      expect(balances['p1'], closeTo(200.0, 0.01));
      expect(balances['p2'], closeTo(-100.0, 0.01));
      expect(balances['p3'], closeTo(-100.0, 0.01));
    });

    test('Selected-person split', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Lunch',
        amount: 100,
        paidById: 'p1',
        participantIds: ['p2', 'p3'], // p1 paid but isn't participating
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2', 'p3'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final balances = service.calculateNetBalances(hangout);

      expect(balances['p1'], closeTo(100.0, 0.01));
      expect(balances['p2'], closeTo(-50.0, 0.01));
      expect(balances['p3'], closeTo(-50.0, 0.01));
    });

    test('Payer included as participant', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Taxi',
        amount: 60,
        paidById: 'p1',
        participantIds: ['p1', 'p2'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final balances = service.calculateNetBalances(hangout);

      expect(balances['p1'], closeTo(30.0, 0.01));
      expect(balances['p2'], closeTo(-30.0, 0.01));
    });

    test('Payer not included as participant', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Gift',
        amount: 50,
        paidById: 'p1',
        participantIds: ['p2'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final balances = service.calculateNetBalances(hangout);

      expect(balances['p1'], closeTo(50.0, 0.01));
      expect(balances['p2'], closeTo(-50.0, 0.01));
    });

    test('Only one participant', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Coffee',
        amount: 10,
        paidById: 'p1',
        participantIds: ['p1'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final balances = service.calculateNetBalances(hangout);

      expect(balances['p1'], closeTo(0.0, 0.01));
      expect(balances['p2'], closeTo(0.0, 0.01));
    });

    test('Multiple expenses with different payers', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Food',
        amount: 90,
        paidById: 'p1',
        participantIds: ['p1', 'p2', 'p3'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final expense2 = ExpenseModel(
        id: 'e2',
        title: 'Gas',
        amount: 60,
        paidById: 'p2',
        participantIds: ['p1', 'p2', 'p3'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2', 'p3'],
        expenseIds: ['e1', 'e2'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1, expense2]);

      final balances = service.calculateNetBalances(hangout);

      // Shares: Food (30 each), Gas (20 each). Total share: 50 each.
      // Paid: p1 (90), p2 (60), p3 (0)
      // Net: p1 (+40), p2 (+10), p3 (-50)
      expect(balances['p1'], closeTo(40.0, 0.01));
      expect(balances['p2'], closeTo(10.0, 0.01));
      expect(balances['p3'], closeTo(-50.0, 0.01));
    });

    test('Decimal amount', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Snacks',
        amount: 10.50,
        paidById: 'p1',
        participantIds: ['p1', 'p2'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final balances = service.calculateNetBalances(hangout);

      expect(balances['p1'], closeTo(5.25, 0.01));
      expect(balances['p2'], closeTo(-5.25, 0.01));
    });

    test('No expenses', () {
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2'],
        expenseIds: [],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: []);

      final balances = service.calculateNetBalances(hangout);

      expect(balances['p1'], 0.0);
      expect(balances['p2'], 0.0);
    });

    test('Already balanced group', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Food',
        amount: 20,
        paidById: 'p1',
        participantIds: ['p1', 'p2'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final expense2 = ExpenseModel(
        id: 'e2',
        title: 'Drinks',
        amount: 20,
        paidById: 'p2',
        participantIds: ['p1', 'p2'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2'],
        expenseIds: ['e1', 'e2'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1, expense2]);

      final balances = service.calculateNetBalances(hangout);

      expect(balances['p1'], closeTo(0.0, 0.01));
      expect(balances['p2'], closeTo(0.0, 0.01));
    });

    test('Rounding difference', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Uber',
        amount: 10,
        paidById: 'p1',
        participantIds: ['p1', 'p2', 'p3'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2', 'p3'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final balances = service.calculateNetBalances(hangout);

      // 10 / 3 = 3.333...
      // p1 paid 10, share 3.333... -> gets 6.666...
      // p2, p3 paid 0, share 3.333... -> owe 3.333...
      expect(balances['p1'], closeTo(6.66, 0.01));
      expect(balances['p2'], closeTo(-3.33, 0.01));
      expect(balances['p3'], closeTo(-3.33, 0.01));
    });
  });

  group('2. Unit tests for settlement generation', () {
    test('One creditor, two debtors', () {
      // p1 pays 90 for p1, p2, p3.
      // Balances: p1 (+60), p2 (-30), p3 (-30)
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Food',
        amount: 90,
        paidById: 'p1',
        participantIds: ['p1', 'p2', 'p3'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2', 'p3'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final settlements = service.generateSettlements(hangout);

      expect(settlements.length, 2);
      expect(
        settlements.any(
          (s) =>
              s.payerId == 'p2' &&
              s.payeeId == 'p1' &&
              (s.amount - 30).abs() < 0.01,
        ),
        isTrue,
      );
      expect(
        settlements.any(
          (s) =>
              s.payerId == 'p3' &&
              s.payeeId == 'p1' &&
              (s.amount - 30).abs() < 0.01,
        ),
        isTrue,
      );
    });

    test('Two creditors, two debtors', () {
      // p1 (+100), p2 (+100), p3 (-100), p4 (-100)
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Food',
        amount: 100,
        paidById: 'p1',
        participantIds: ['p3', 'p4'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final expense2 = ExpenseModel(
        id: 'e2',
        title: 'Gas',
        amount: 100,
        paidById: 'p2',
        participantIds: ['p3', 'p4'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2', 'p3', 'p4'],
        expenseIds: ['e1', 'e2'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1, expense2]);

      final settlements = service.generateSettlements(hangout);

      expect(settlements.length, 2);
      final totalSettled = settlements.fold<double>(
        0,
        (sum, s) => sum + s.amount,
      );
      expect(totalSettled, closeTo(200.0, 0.01));
    });

    test('No settlement needed', () {
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Food',
        amount: 20,
        paidById: 'p1',
        participantIds: ['p1'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2'],
        expenseIds: ['e1'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1]);

      final settlements = service.generateSettlements(hangout);

      expect(settlements, isEmpty);
    });

    test('Settlement total equals debt total', () {
      // p1 pays 100 (split all 4)
      // p2 pays 50 (split all 4)
      final expense1 = ExpenseModel(
        id: 'e1',
        title: 'Food',
        amount: 100,
        paidById: 'p1',
        participantIds: ['p1', 'p2', 'p3', 'p4'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final expense2 = ExpenseModel(
        id: 'e2',
        title: 'Gas',
        amount: 50,
        paidById: 'p2',
        participantIds: ['p1', 'p2', 'p3', 'p4'],
        date: DateTime.now(),
        splitType: SplitType.equal,
      );
      final hangout = HangoutModel(
        id: 'h1',
        title: 'Trip',
        participantIds: ['p1', 'p2', 'p3', 'p4'],
        expenseIds: ['e1', 'e2'],
        startDate: DateTime.now(),
      );
      final service = SplitCalculatorService(allExpenses: [expense1, expense2]);

      final balances = service.calculateNetBalances(hangout);
      final totalDebt = balances.values
          .where((b) => b < 0)
          .fold<double>(0, (sum, b) => sum + b.abs());

      final settlements = service.generateSettlements(hangout);
      final totalSettlementAmount = settlements.fold<double>(
        0,
        (sum, s) => sum + s.amount,
      );

      expect(totalSettlementAmount, closeTo(totalDebt, 0.01));
    });
  });
}
