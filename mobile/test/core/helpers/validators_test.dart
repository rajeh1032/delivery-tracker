import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/helpers/validators.dart';

void main() {
  group('Validators', () {
    test('validateRecipientName validates non-empty and length between 2 and 100', () {
      expect(Validators.validateRecipientName(null, 'Required'), 'Required');
      expect(Validators.validateRecipientName('', 'Required'), 'Required');
      expect(Validators.validateRecipientName('  ', 'Required'), 'Required');
      expect(Validators.validateRecipientName('A', 'Required'), 'Required');
      expect(Validators.validateRecipientName('Ahmed', 'Required'), isNull);
      expect(Validators.validateRecipientName('A' * 101, 'Required'), 'Required');
    });

    test('validateNote validates maximum length of 500 characters', () {
      expect(Validators.validateNote(null, 'Too long'), isNull);
      expect(Validators.validateNote('', 'Too long'), isNull);
      expect(Validators.validateNote('Leave at front door', 'Too long'), isNull);
      expect(Validators.validateNote('N' * 501, 'Too long'), 'Too long');
    });

    test('validateRequired checks for null', () {
      expect(Validators.validateRequired(null, 'Required'), 'Required');
      expect(Validators.validateRequired('Value', 'Required'), isNull);
      expect(Validators.validateRequired(1, 'Required'), isNull);
    });
  });
}
