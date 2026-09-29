/// Centralized application constants ensuring zero hardcoded strings.
abstract final class AppConstants {
  /// Default payment method fallback.
  static const String defaultPaymentMethod = 'cash';

  /// Standard cash payment method key.
  static const String cashPaymentMethod = 'cash';

  /// Standard KNet payment method key.
  static const String knetPaymentMethod = 'knet';
}
