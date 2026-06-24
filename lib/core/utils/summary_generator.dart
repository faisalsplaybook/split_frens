import '../../features/hangouts/data/models/hangout_model.dart';
import '../../features/hangouts/data/models/expense_model.dart';
import '../../features/hangouts/data/models/person_model.dart';
import '../../features/hangouts/data/models/settlement_model.dart';
import '../../features/hangouts/data/services/split_calculator_service.dart';
import 'money_formatter.dart';

class SummaryGenerator {
  static String generateSummary({
    required HangoutModel hangout,
    required List<ExpenseModel> expenses,
    required List<PersonModel> people,
    required List<SettlementModel> settlements,
    required double totalExpense,
    required SplitCalculatorService calculator,
  }) {
    final buffer = StringBuffer();
    final convertedTotals = calculator.calculateTotalConverted(hangout);

    String formatBase(double amt) {
      return MoneyFormatter.format(amt, currencyCode: hangout.defaultCurrency);
    }

    String getConvertedSuffix(double baseAmount) {
      if (totalExpense <= 0 || convertedTotals.isEmpty) return '';
      final ratio = baseAmount / totalExpense;
      final parts = convertedTotals.entries.map(
        (e) => MoneyFormatter.format(e.value * ratio, currencyCode: e.key),
      );
      return ' (${parts.join(', ')})';
    }

    // Header
    buffer.writeln('SplitFrens Summary');
    buffer.writeln(hangout.title);
    buffer.writeln();

    // Total and People
    buffer.writeln(
      'Total: ${formatBase(totalExpense)}${getConvertedSuffix(totalExpense)}',
    );
    final peopleNames = people.map((p) => p.name).join(', ');
    buffer.writeln('People: $peopleNames');
    buffer.writeln();

    // Expenses
    buffer.writeln('Expenses:');
    for (final expense in expenses) {
      final payer = people
          .firstWhere(
            (p) => p.id == expense.paidById,
            orElse: () => PersonModel(id: '', name: 'Unknown'),
          )
          .name;

      String expSuffix = '';
      if (expense.convertedAmount != null && expense.currency != null) {
        expSuffix =
            ' (${MoneyFormatter.format(expense.convertedAmount!, currencyCode: expense.currency!)})';
      }
      buffer.writeln(
        '- ${expense.title}: ${formatBase(expense.amount)}$expSuffix paid by $payer',
      );
    }
    buffer.writeln();

    // Settlements
    buffer.writeln('Settlements:');
    for (final s in settlements) {
      final from = people
          .firstWhere(
            (p) => p.id == s.payerId,
            orElse: () => PersonModel(id: '', name: 'Unknown'),
          )
          .name;
      final to = people
          .firstWhere(
            (p) => p.id == s.payeeId,
            orElse: () => PersonModel(id: '', name: 'Unknown'),
          )
          .name;
      final status = s.isPaid ? 'Paid' : 'Unpaid';
      buffer.writeln(
        '- $from pays $to ${formatBase(s.amount)}${getConvertedSuffix(s.amount)} - $status',
      );
    }

    return buffer.toString().trim();
  }
}
