/// A model representing the result of a currency conversion if the app supports multi-currency.
class CurrencyConversionResult {
  // e.g., 'USD'
  final String fromCurrency;
  // e.g., 'EUR'
  final String toCurrency;
  // The exchange rate (e.g., 0.92)
  final double rate;
  // When this rate was fetched
  final DateTime lastUpdated;

  CurrencyConversionResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.lastUpdated,
  });

  CurrencyConversionResult copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? rate,
    DateTime? lastUpdated,
  }) {
    return CurrencyConversionResult(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
