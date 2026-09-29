import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResult', () {
    test('ApiSuccessResult holds data and identifies as success', () {
      const result = ApiResult<String>.success('test_data');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 'test_data');

      final value = result.when(
        success: (data) => 'got: $data',
        failure: (msg, code, sc) => 'failed',
      );
      expect(value, 'got: test_data');
    });

    test('ApiErrorResult holds message, code, statusCode', () {
      const result = ApiResult<String>.failure(
        'network timeout',
        code: 'TIMEOUT',
        statusCode: 504,
      );

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);

      final value = result.when(
        success: (data) => 'success',
        failure: (msg, code, sc) => '$code: $msg ($sc)',
      );
      expect(value, 'TIMEOUT: network timeout (504)');
    });

    test('equality checks work for ApiSuccessResult and ApiErrorResult', () {
      const s1 = ApiSuccessResult(42);
      const s2 = ApiSuccessResult(42);
      const s3 = ApiSuccessResult(43);

      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));

      const e1 = ApiErrorResult('err', code: 'E1', statusCode: 400);
      const e2 = ApiErrorResult('err', code: 'E1', statusCode: 400);
      const e3 = ApiErrorResult('err2', code: 'E1', statusCode: 400);

      expect(e1, equals(e2));
      expect(e1, isNot(equals(e3)));
    });
  });
}
