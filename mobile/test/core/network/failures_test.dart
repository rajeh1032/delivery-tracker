import 'dart:io';
import 'package:dio/dio.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    test('TransientFailure has isRetryable true', () {
      const failure = TransientFailure(
        errorMessage: 'Temporary issue',
        code: '503',
      );
      expect(failure.isRetryable, isTrue);
      expect(failure.errorMessage, 'Temporary issue');
      expect(failure.code, '503');
    });

    test('PermanentFailure has isRetryable false', () {
      const failure = PermanentFailure(
        errorMessage: 'Invalid payload',
        code: NetworkConstants.validationError,
      );
      expect(failure.isRetryable, isFalse);
      expect(failure.errorMessage, 'Invalid payload');
      expect(failure.code, NetworkConstants.validationError);
    });

    test('Base Failure has isRetryable false', () {
      const failure = Failure(errorMessage: 'Generic failure');
      expect(failure.isRetryable, isFalse);
    });

    test('Equality and toString for Failure classes', () {
      const f1 = TransientFailure(errorMessage: 'err', code: '500');
      const f2 = TransientFailure(errorMessage: 'err', code: '500');
      const f3 = PermanentFailure(errorMessage: 'err', code: '500');

      expect(f1, equals(f2));
      expect(f1, isNot(equals(f3)));
      expect(f1.toString(), contains('TransientFailure'));
    });

    group('ServerFailure.fromDioError', () {
      final requestOptions = RequestOptions(path: '/test');

      test('connectionTimeout maps to TransientFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.errorMessage, NetworkConstants.connectionTimeoutMessage);
      });

      test('sendTimeout maps to TransientFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.sendTimeout,
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.errorMessage, NetworkConstants.sendTimeoutMessage);
      });

      test('receiveTimeout maps to TransientFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.receiveTimeout,
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.errorMessage, NetworkConstants.receiveTimeoutMessage);
      });

      test('connectionError maps to TransientFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.errorMessage, NetworkConstants.connectionErrorMessage);
      });

      test('badCertificate maps to PermanentFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badCertificate,
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<PermanentFailure>());
        expect(failure.isRetryable, isFalse);
        expect(failure.errorMessage, NetworkConstants.badCertificateMessage);
      });

      test('cancel maps to TransientFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.cancel,
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.errorMessage, NetworkConstants.cancelMessage);
      });

      test('unknown with SocketException maps to TransientFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.unknown,
          error: const SocketException('Network unreachable'),
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.code, NetworkConstants.noInternet);
      });

      test('transformTimeout maps to TransientFailure', () {
        final err = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.transformTimeout,
        );
        final failure = ServerFailure.fromDioError(dioException: err);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
      });
    });

    group('ServerFailure.fromResponse', () {
      final requestOptions = RequestOptions(path: '/deliveries');

      test('null response returns TransientFailure', () {
        final failure = ServerFailure.fromResponse(null);
        expect(failure, isA<TransientFailure>());
        expect(failure.errorMessage, NetworkConstants.noResponseMessage);
      });

      test('400 validation error extracts machine code and is permanent', () {
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 400,
          data: {
            NetworkConstants.keyCode: NetworkConstants.validationError,
            NetworkConstants.keyMessage: 'recipient_name is required',
          },
        );
        final failure = ServerFailure.fromResponse(response);
        expect(failure, isA<PermanentFailure>());
        expect(failure.isRetryable, isFalse);
        expect(failure.code, NetworkConstants.validationError);
        expect(failure.errorMessage, 'recipient_name is required');
      });

      test('404 not found error is permanent', () {
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 404,
          data: {
            NetworkConstants.keyCode: NetworkConstants.deliveryNotFound,
            NetworkConstants.keyMessage: 'Delivery not found',
          },
        );
        final failure = ServerFailure.fromResponse(response);
        expect(failure, isA<PermanentFailure>());
        expect(failure.isRetryable, isFalse);
        expect(failure.code, NetworkConstants.deliveryNotFound);
        expect(failure.errorMessage, 'Delivery not found');
      });

      test('409 delivery conflict error is permanent', () {
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 409,
          data: {
            NetworkConstants.keyCode: NetworkConstants.deliveryConflict,
            NetworkConstants.keyMessage:
                NetworkConstants.deliveryConflictMessage,
          },
        );
        final failure = ServerFailure.fromResponse(response);
        expect(failure, isA<PermanentFailure>());
        expect(failure.isRetryable, isFalse);
        expect(failure.code, NetworkConstants.deliveryConflict);
      });

      test('500 server error maps to TransientFailure and is retryable', () {
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 500,
          data: {
            NetworkConstants.keyMessage: 'Internal server error',
          },
        );
        final failure = ServerFailure.fromResponse(response);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.errorMessage, 'Internal server error');
        expect(failure.code, '500');
      });

      test('503 gateway unavailable is transient', () {
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 503,
          data: null,
        );
        final failure = ServerFailure.fromResponse(response);
        expect(failure, isA<TransientFailure>());
        expect(failure.isRetryable, isTrue);
        expect(failure.errorMessage, NetworkConstants.serverErrorMessage);
      });

      test('extracts error field when message is absent', () {
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 400,
          data: {
            NetworkConstants.keyError: 'Bad Request Parameter',
            NetworkConstants.keyCode: 'BAD_PARAM',
          },
        );
        final failure = ServerFailure.fromResponse(response);
        expect(failure.errorMessage, 'Bad Request Parameter');
        expect(failure.code, 'BAD_PARAM');
      });

      test('handles raw string error body', () {
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 500,
          data: 'Gateway timeout from upstream proxy',
        );
        final failure = ServerFailure.fromResponse(response);
        expect(failure.errorMessage, 'Gateway timeout from upstream proxy');
      });
    });
  });
}
