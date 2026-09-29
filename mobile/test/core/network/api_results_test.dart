import 'package:dio/dio.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
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
      expect(result.failureOrNull?.errorMessage, 'network timeout');
      expect((result as ApiErrorResult<String>).failure.code, 'TIMEOUT');
    });


    test('ApiErrorResult.fromFailure constructs correct error result', () {
      const failure = TransientFailure(
        errorMessage: 'Server busy',
        code: '503',
      );
      final result = ApiErrorResult<String>.fromFailure(failure, statusCode: 503);

      expect(result.message, 'Server busy');
      expect(result.code, '503');
      expect(result.statusCode, 503);
      expect(result.failure, equals(failure));
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

    group('safeApiCall', () {
      test('wraps successful asynchronous return in ApiSuccessResult',
          () async {
        final result = await safeApiCall(() async => 'hello_network');
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, 'hello_network');
      });

      test('catches DioException and maps to ApiErrorResult with ServerFailure',
          () async {
        final result = await safeApiCall<String>(() async {
          throw DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
          );
        });

        expect(result.isFailure, isTrue);
        final error = result as ApiErrorResult<String>;
        expect(error.message, NetworkConstants.connectionTimeoutMessage);
        expect(error.failure, isA<TransientFailure>());
        expect(error.failure.isRetryable, isTrue);
      });

      test('catches non-Dio exception and maps to ApiErrorResult with Failure',
          () async {
        final result = await safeApiCall<String>(() async {
          throw Exception('Something unexpected broke');
        });

        expect(result.isFailure, isTrue);
        final error = result as ApiErrorResult<String>;
        expect(error.message, contains('Something unexpected broke'));
        expect(error.code, NetworkConstants.unknownError);
      });
    });

    group('safeLocalCall', () {
      test('returns ApiSuccessResult when local call succeeds', () async {
        final result = await safeLocalCall(() async => 100);
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, 100);
      });

      test('returns ApiErrorResult when local call throws', () async {
        final result = await safeLocalCall<int>(() async {
          throw StateError('Database box closed');
        });

        expect(result.isFailure, isTrue);
        final error = result as ApiErrorResult<int>;
        expect(error.message, contains('Database box closed'));
        expect(error.code, NetworkConstants.unknownError);
      });
    });
  });
}
