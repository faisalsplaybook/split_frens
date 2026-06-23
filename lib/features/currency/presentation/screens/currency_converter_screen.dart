import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/currency_constants.dart';
import '../providers/currency_provider.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  final String hangoutId;

  const CurrencyConverterScreen({super.key, required this.hangoutId});

  @override
  ConsumerState<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends ConsumerState<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  String _fromCurrency = CurrencyConstants.supportedCurrencies[1]; // USD
  String _toCurrency = CurrencyConstants.supportedCurrencies[0]; // BDT

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _fromCurrency,
                    items: CurrencyConstants.supportedCurrencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _fromCurrency = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _toCurrency,
                    items: CurrencyConstants.supportedCurrencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _toCurrency = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }
                ref
                    .read(currencyProvider.notifier)
                    .convert(
                      amount: amount,
                      fromCurrency: _fromCurrency,
                      toCurrency: _toCurrency,
                    );
              },
              child: const Text('Convert'),
            ),
            const SizedBox(height: 24),
            if (currencyState.status == CurrencyStateStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (currencyState.status == CurrencyStateStatus.error)
              Center(
                child: Text(
                  currencyState.errorMessage ?? 'Conversion failed',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            else if (currencyState.status == CurrencyStateStatus.success &&
                currencyState.result != null) ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Converted Result',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currencyState.convertedAmount.toStringAsFixed(2)} $_toCurrency',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rate: 1 $_fromCurrency = ${currencyState.result!.rate.toStringAsFixed(4)} $_toCurrency',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: ${currencyState.result!.lastUpdated.toLocal().toString().split('.')[0]}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  context.pop(currencyState.convertedAmount);
                },
                icon: const Icon(Icons.check),
                label: const Text('Use Converted Amount in Expense'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
