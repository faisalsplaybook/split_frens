import 'package:flutter_test/flutter_test.dart';
import 'package:split_frens/core/utils/validators.dart';

void main() {
  group('3. Validator tests', () {
    test('Empty hangout name', () {
      expect(AppValidators.validateHangoutName(''), isNotNull);
      expect(AppValidators.validateHangoutName('   '), isNotNull);
      expect(AppValidators.validateHangoutName(null), isNotNull);
      // Valid case
      expect(AppValidators.validateHangoutName('Trip to Paris'), isNull);
    });

    test('Missing base currency in travel mode', () {
      // Travel mode ON
      expect(AppValidators.validateCurrency(null, true), isNotNull);
      expect(AppValidators.validateCurrency('', true), isNotNull);
      expect(AppValidators.validateCurrency('USD', true), isNull);
      
      // Travel mode OFF
      expect(AppValidators.validateCurrency(null, false), isNull);
    });

    test('Empty person name', () {
      expect(AppValidators.validateRequiredText('', 'Person name'), isNotNull);
      expect(AppValidators.validateRequiredText(null, 'Person name'), isNotNull);
      expect(AppValidators.validateRequiredText('Alice', 'Person name'), isNull);
    });

    test('Duplicate person name', () {
      final existingNames = ['Alice', 'Bob'];
      expect(AppValidators.validateDuplicateName('Alice', existingNames), isNotNull);
      expect(AppValidators.validateDuplicateName('Charlie', existingNames), isNull);
    });

    test('Invalid amount', () {
      expect(AppValidators.validateAmount(''), isNotNull);
      expect(AppValidators.validateAmount('abc'), isNotNull);
      expect(AppValidators.validateAmount('-50'), isNotNull);
      expect(AppValidators.validateAmount('0'), isNotNull);
      expect(AppValidators.validateAmount('50'), isNull);
      expect(AppValidators.validateAmount('50.5'), isNull);
    });

    test('Missing payer', () {
      expect(AppValidators.validatePayer(null), isNotNull);
      expect(AppValidators.validatePayer(''), isNotNull);
      expect(AppValidators.validatePayer('payer-id-1'), isNull);
    });

    test('No participants selected', () {
      expect(AppValidators.validateParticipants([]), isNotNull);
      expect(AppValidators.validateParticipants(['p1']), isNull);
    });
  });
}
