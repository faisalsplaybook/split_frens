import 'package:intl/intl.dart';

import '../../features/settings/data/services/settings_service.dart';

/// A utility class for formatting currency amounts across the app.
class MoneyFormatter {
  MoneyFormatter._();

  /// Formats a double amount into a string with the appropriate currency symbol.
  /// Example: 1200.0 -> $1,200 or ৳1,200
  static String format(double amount, {String? currencyCode}) {
    final currency = currencyCode ?? SettingsService.getDefaultCurrency();
    final formatter = NumberFormat.simpleCurrency(
      name: currency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Gets the currency symbol for a given currency code.
  static String getSymbol({String? currencyCode}) {
    final currency = currencyCode ?? SettingsService.getDefaultCurrency();
    final formatter = NumberFormat.simpleCurrency(name: currency);
    return formatter.currencySymbol;
  }
}
