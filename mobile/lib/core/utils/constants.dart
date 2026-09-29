/// Centralized application constants ensuring zero hardcoded strings.
abstract final class AppConstants {
  /// Default payment method fallback.
  static const String defaultPaymentMethod = paymentMethodCash;

  /// Standard cash payment method key.
  static const String paymentMethodCash = 'cash';

  /// Standard InstaPay payment method key.
  static const String paymentMethodInstapay = 'instapay';

  /// Shared preferences key for selected language code.
  static const String languageCode = 'selected_language_code';

  /// Default application language code.
  static const String defaultLanguage = englishLanguage;

  /// Arabic language code.
  static const String arabicLanguage = 'ar';

  /// English language code.
  static const String englishLanguage = 'en';
}

