class AppValidators {
  static String? validateRequiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateHangoutName(String? value) {
    final requiredError = validateRequiredText(value, 'Hangout name');
    if (requiredError != null) return requiredError;

    if (value!.trim().length < 3) {
      return 'Hangout name must be at least 3 characters';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }

  // Currency is only required when travel mode is enabled.
  static String? validateCurrency(String? value, bool isTravelModeEnabled) {
    if (!isTravelModeEnabled) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Base currency is required for travel mode';
    }
    return null;
  }

  static String? validateDuplicateName(
    String? value,
    List<String> existingNames,
  ) {
    final requiredError = validateRequiredText(value, 'Person name');
    if (requiredError != null) return requiredError;

    if (existingNames.contains(value!.trim())) {
      return 'Name already exists';
    }
    return null;
  }

  static String? validatePayer(String? payerId) {
    if (payerId == null || payerId.isEmpty) {
      return 'Payer is required';
    }
    return null;
  }

  static String? validateParticipants(List<String> participantIds) {
    if (participantIds.isEmpty) {
      return 'At least one participant must be selected';
    }
    return null;
  }
}
