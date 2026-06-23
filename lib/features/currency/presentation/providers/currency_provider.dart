import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/currency_api_service.dart';
import '../../data/repositories/currency_repository.dart';
import '../../../../features/hangouts/data/models/currency_conversion_result.dart';

final currencyApiServiceProvider = Provider((ref) => CurrencyApiService());

final currencyRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(currencyApiServiceProvider);
  return CurrencyRepository(apiService);
});

// State enum
enum CurrencyStateStatus { initial, loading, success, error }

class CurrencyState {
  final CurrencyStateStatus status;
  final CurrencyConversionResult? result;
  final String? errorMessage;
  final double convertedAmount;

  CurrencyState({
    this.status = CurrencyStateStatus.initial,
    this.result,
    this.errorMessage,
    this.convertedAmount = 0.0,
  });

  CurrencyState copyWith({
    CurrencyStateStatus? status,
    CurrencyConversionResult? result,
    String? errorMessage,
    double? convertedAmount,
  }) {
    return CurrencyState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }
}

class CurrencyNotifier extends Notifier<CurrencyState> {
  late final CurrencyRepository _repository;

  @override
  CurrencyState build() {
    _repository = ref.watch(currencyRepositoryProvider);
    return CurrencyState();
  }

  Future<void> convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    state = state.copyWith(status: CurrencyStateStatus.loading);
    try {
      final result = await _repository.convert(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );
      state = state.copyWith(
        status: CurrencyStateStatus.success,
        result: result,
        convertedAmount: amount * result.rate,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CurrencyStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, CurrencyState>(() {
  return CurrencyNotifier();
});
