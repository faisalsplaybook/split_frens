import '../../features/hangouts/data/models/hangout_model.dart';
import '../../features/hangouts/data/models/expense_model.dart';
import '../../features/hangouts/data/models/person_model.dart';
import '../../features/hangouts/data/models/settlement_model.dart';

class SummaryGenerator {
  static String generateSummary({
    required HangoutModel hangout,
    required List<ExpenseModel> expenses,
    required List<PersonModel> people,
    required List<SettlementModel> settlements,
    required double totalExpense,
    String currencySymbol = '৳',
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('SplitFrens Summary');
    buffer.writeln(hangout.title);
    buffer.writeln();
    
    // Total and People
    buffer.writeln('Total: $currencySymbol${totalExpense.toStringAsFixed(0)}');
    final peopleNames = people.map((p) => p.name).join(', ');
    buffer.writeln('People: $peopleNames');
    buffer.writeln();
    
    // Expenses
    buffer.writeln('Expenses:');
    for (final expense in expenses) {
      final payer = people.firstWhere(
        (p) => p.id == expense.paidById, 
        orElse: () => PersonModel(id: '', name: 'Unknown')
      ).name;
      buffer.writeln('- ${expense.title}: $currencySymbol${expense.amount.toStringAsFixed(0)} paid by $payer');
    }
    buffer.writeln();
    
    // Settlements
    buffer.writeln('Settlements:');
    for (final s in settlements) {
      final from = people.firstWhere(
        (p) => p.id == s.payerId, 
        orElse: () => PersonModel(id: '', name: 'Unknown')
      ).name;
      final to = people.firstWhere(
        (p) => p.id == s.payeeId, 
        orElse: () => PersonModel(id: '', name: 'Unknown')
      ).name;
      final status = s.isPaid ? 'Paid' : 'Unpaid';
      buffer.writeln('- $from pays $to $currencySymbol${s.amount.toStringAsFixed(0)} - $status');
    }
    
    return buffer.toString().trim();
  }
}
