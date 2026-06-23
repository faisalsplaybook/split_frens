import '../services/currency_api_service.dart';
import '../../../../features/hangouts/data/models/currency_conversion_result.dart';

class CurrencyRepository {
  final CurrencyApiService _apiService;

  CurrencyRepository(this._apiService);

  Future<CurrencyConversionResult> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      return await _apiService.convert(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
    } catch (e) {
      throw Exception('Failed to convert currency: $e');
    }
  }
}
