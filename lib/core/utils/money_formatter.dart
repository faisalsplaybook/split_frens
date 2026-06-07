import 'package:intl/intl.dart';

/// A utility class for formatting currency amounts across the app.
class MoneyFormatter {
  // We use a private constructor to prevent creating objects of this class,
  // since we only need its static methods.
  MoneyFormatter._();

  /// Formats a double amount into a string with the BDT currency symbol and commas.
  /// Example: 1200.0 -> ৳1,200
  static String format(double amount) {
    // We use the intl package's NumberFormat
    final formatter = NumberFormat.currency(
      symbol: '৳',
      decimalDigits: 0, // No decimal places needed for this example
    );
    return formatter.format(amount);
  }
}
