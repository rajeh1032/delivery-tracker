import 'package:delivery_tracker/core/helpers/spacing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spacing helpers', () {
    test('verticalSpace creates SizedBox with requested height', () {
      final box = verticalSpace(16.0);
      expect(box.height, 16.0);
      expect(box.width, isNull);
    });

    test('horizontalSpace creates SizedBox with requested width', () {
      final box = horizontalSpace(24.0);
      expect(box.width, 24.0);
      expect(box.height, isNull);
    });
  });
}
