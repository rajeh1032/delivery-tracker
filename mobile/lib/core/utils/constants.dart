/// Centralized application constants ensuring zero hardcoded strings.
abstract final class AppConstants {
  /// Default payment method fallback.
  static const String defaultPaymentMethod = paymentMethodCash;

  /// Standard cash payment method key.
  static const String paymentMethodCash = 'cash';

  /// Standard InstaPay payment method key.
  static const String paymentMethodInstapay = 'instapay';
}
