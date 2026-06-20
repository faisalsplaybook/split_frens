// ==========================================
// Form Validators
// ==========================================
// A validator is a function that checks if the input in a text field is correct.
// It returns a String (the error message) if there's a problem, or null if it's perfectly fine.
class AppValidators {
  // 1. Basic required text validation
  static String? validateRequiredText(String? value, String fieldName) {
    // If the user hasn't typed anything or just typed spaces, return an error.
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    // Returning null means "No error, everything is good!"
    return null;
  }

  // 2. Hangout Name validation
  static String? validateHangoutName(String? value) {
    // We can reuse our basic required text validator
    final requiredError = validateRequiredText(value, 'Hangout name');
    if (requiredError != null) return requiredError;

    // We can also add custom logic, like making sure the name isn't too short
    if (value!.trim().length < 3) {
      return 'Hangout name must be at least 3 characters';
    }
    return null;
  }

  // 3. Amount validation (for when we add expenses later)
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }

    // Try to parse the text into a number (double)
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }

  // 4. Currency validation (required only if travel mode is ON)
  static String? validateCurrency(String? value, bool isTravelModeEnabled) {
    // If travel mode is OFF, we don't care about currency, so it's always valid (null).
    if (!isTravelModeEnabled) return null;

    // If travel mode IS on, currency is required!
    if (value == null || value.trim().isEmpty) {
      return 'Base currency is required for travel mode';
    }
    return null;
  }
}
