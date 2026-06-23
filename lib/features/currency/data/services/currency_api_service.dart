import 'package:dio/dio.dart';
import '../../../../features/hangouts/data/models/currency_conversion_result.dart';

class CurrencyApiService {
  final Dio _dio;

  CurrencyApiService({Dio? dio}) : _dio = dio ?? Dio();

  Future<CurrencyConversionResult> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final response = await _dio.get('https://open.er-api.com/v6/latest/$fromCurrency');
      
      if (response.statusCode == 200) {
        final rates = response.data['rates'] as Map<String, dynamic>;
        
        if (!rates.containsKey(toCurrency)) {
          throw Exception('Currency $toCurrency not supported');
        }
        
        final rate = (rates[toCurrency] as num).toDouble();
        final lastUpdated = DateTime.fromMillisecondsSinceEpoch(
          (response.data['time_last_update_unix'] as int) * 1000,
        );
        
        return CurrencyConversionResult(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          rate: rate,
          lastUpdated: lastUpdated,
        );
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Currency API Error: $e');
    }
  }
}
