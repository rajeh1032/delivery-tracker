import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:delivery_tracker/core/helpers/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);
  });
  group('Formatters', () {
    test('formatAmountDue formats 3 decimal digits and currency symbol', () {
      final formatted = Formatters.formatAmountDue(18.75);
      expect(formatted.contains('18.750'), isTrue);
      expect(formatted.contains('KWD'), isTrue);
    });

    test('formatDateTime handles null and valid date', () {
      expect(Formatters.formatDateTime(null), isEmpty);

      final date = DateTime(2026, 9, 29, 14, 30);
      final formatted = Formatters.formatDateTime(date, locale: 'en');
      expect(formatted.contains('2026/09/29'), isTrue);
    });

    test('formatTime formats hour and minute with period', () {
      expect(Formatters.formatTime(null), isEmpty);

      final date = DateTime(2026, 9, 29, 14, 30);
      final formatted = Formatters.formatTime(date, locale: 'en');
      expect(formatted.contains('02:30'), isTrue);
    });
  });
}
