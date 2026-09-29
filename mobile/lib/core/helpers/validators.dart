/// Centralized form input validators.
abstract final class Validators {
  /// Validates delivery recipient name (mandatory, 2-100 characters).
  static String? validateRecipientName(String? value, String requiredError) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return requiredError;
    }
    if (trimmed.length < 2) {
      return requiredError;
    }
    if (trimmed.length > 100) {
      return requiredError;
    }
    return null;
  }

  /// Validates optional delivery note (maximum 500 characters).
  static String? validateNote(String? value, String maxError) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > 500) {
      return maxError;
    }
    return null;
  }

  /// Validates required selection (e.g., failure reason dropdown).
  static String? validateRequired<T>(T? value, String requiredError) {
    if (value == null) {
      return requiredError;
    }
    return null;
  }
}
