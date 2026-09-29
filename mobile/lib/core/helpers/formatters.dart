import 'package:intl/intl.dart';

/// Centralized data formatters for currency, phone, and timestamps.
abstract final class Formatters {
  /// Formats amount with 3 decimal digits and currency symbol (e.g., 18.750 KWD).
  static String formatAmountDue(
    double amount, {
    String currency = 'KWD',
    String? locale,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currency,
      decimalDigits: 3,
      customPattern: '#,##0.000 \u00a4',
    );
    return formatter.format(amount).trim();
  }

  /// Formats date and time according to active locale.
  static String formatDateTime(DateTime? dateTime, {String? locale}) {
    if (dateTime == null) return '';
    final formatter = DateFormat('yyyy/MM/dd - hh:mm a', locale);
    return formatter.format(dateTime);
  }

  /// Formats relative time elapsed (e.g., 5 mins ago).
  static String formatTime(DateTime? dateTime, {String? locale}) {
    if (dateTime == null) return '';
    final formatter = DateFormat('hh:mm a', locale);
    return formatter.format(dateTime);
  }
}
