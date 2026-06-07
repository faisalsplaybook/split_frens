import 'package:intl/intl.dart';

/// A utility class for formatting dates across the app.
class DateFormatter {
  // Private constructor
  DateFormatter._();

  /// Formats a DateTime object into a string like "May 17, 2026".
  static String format(DateTime date) {
    // MMM translates to the short month name (e.g. May)
    // d translates to the day of the month without padding (e.g. 17)
    // yyyy translates to the 4-digit year (e.g. 2026)
    return DateFormat('MMM d, yyyy').format(date);
  }
}
