import 'dart:io';
import 'package:dio/dio.dart';
import 'network_constants.dart';

/// Base failure representing an error in domain or data operations.
class Failure {
  final String errorMessage;
  final String code;

  const Failure({
    required this.errorMessage,
    this.code = NetworkConstants.defaultErrorCode,
  });

  /// Indicates whether the failure is transient and can be retried.
  bool get isRetryable => false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          errorMessage == other.errorMessage &&
          code == other.code;

  @override
  int get hashCode => Object.hash(errorMessage, code);

  @override
  String toString() => '$runtimeType(code: $code, message: $errorMessage)';
}

/// Represents failures originating from the remote API server.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.errorMessage,
    super.code,
  });

  @override
  bool get isRetryable => this is TransientFailure;

  /// Constructs a [ServerFailure] from a [DioException].
  factory ServerFailure.fromDioError({required DioException dioException}) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return TransientFailure(
          errorMessage: NetworkConstants.connectionTimeoutMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.defaultErrorCode,
        );
      case DioExceptionType.sendTimeout:
        return TransientFailure(
          errorMessage: NetworkConstants.sendTimeoutMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.defaultErrorCode,
        );
      case DioExceptionType.receiveTimeout:
        return TransientFailure(
          errorMessage: NetworkConstants.receiveTimeoutMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.defaultErrorCode,
        );
      case DioExceptionType.connectionError:
        return TransientFailure(
          errorMessage: NetworkConstants.connectionErrorMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.noInternet,
        );
      case DioExceptionType.badCertificate:
        return PermanentFailure(
          errorMessage: NetworkConstants.badCertificateMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.defaultErrorCode,
        );
      case DioExceptionType.cancel:
        return TransientFailure(
          errorMessage: NetworkConstants.cancelMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.defaultErrorCode,
        );
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(dioException.response);
      case DioExceptionType.transformTimeout:
        return TransientFailure(
          errorMessage: NetworkConstants.unexpectedErrorMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.unknownError,
        );
      case DioExceptionType.unknown:
        final error = dioException.error;

        if (error is SocketException) {
          return const TransientFailure(
            errorMessage: NetworkConstants.connectionErrorMessage,
            code: NetworkConstants.noInternet,
          );
        }
        return TransientFailure(
          errorMessage: NetworkConstants.unexpectedErrorMessage,
          code: dioException.response?.statusCode?.toString() ??
              NetworkConstants.unknownError,
        );
    }
  }

  /// Constructs a [ServerFailure] from a [Response], extracting machine-readable codes.
  factory ServerFailure.fromResponse(Response? response) {
    if (response == null) {
      return const TransientFailure(
        errorMessage: NetworkConstants.noResponseMessage,
        code: NetworkConstants.defaultErrorCode,
      );
    }

    final int statusCode = response.statusCode ?? 0;
    String errorMessage = NetworkConstants.unexpectedErrorMessage;
    String code = statusCode.toString();

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey(NetworkConstants.keyCode) &&
          data[NetworkConstants.keyCode] != null) {
        code = data[NetworkConstants.keyCode].toString();
      }
      if (data.containsKey(NetworkConstants.keyMessage) &&
          data[NetworkConstants.keyMessage] != null) {
        errorMessage = data[NetworkConstants.keyMessage].toString();
      } else if (data.containsKey(NetworkConstants.keyError) &&
          data[NetworkConstants.keyError] != null) {
        errorMessage = data[NetworkConstants.keyError].toString();
      }
    } else if (data is String && data.isNotEmpty) {
      errorMessage = data;
    }

    if (statusCode == 400 ||
        statusCode == 404 ||
        statusCode == 409 ||
        (statusCode >= 400 && statusCode < 500)) {
      if (statusCode == 404 &&
          errorMessage == NetworkConstants.unexpectedErrorMessage) {
        errorMessage = NetworkConstants.resourceNotFoundMessage;
      }
      return PermanentFailure(errorMessage: errorMessage, code: code);
    } else if (statusCode == 500 ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504 ||
        statusCode >= 500) {
      if (errorMessage == NetworkConstants.unexpectedErrorMessage) {
        errorMessage = NetworkConstants.serverErrorMessage;
      }
      return TransientFailure(errorMessage: errorMessage, code: code);
    }

    return ServerFailure(errorMessage: errorMessage, code: code);
  }
}

/// Represents a retryable failure (timeouts, network dropouts, 5xx server errors).
class TransientFailure extends ServerFailure {
  const TransientFailure({
    required super.errorMessage,
    super.code,
  });

  @override
  bool get isRetryable => true;
}

/// Represents a non-retryable failure (validation error, 404 not found, 409 conflict).
class PermanentFailure extends ServerFailure {
  const PermanentFailure({
    required super.errorMessage,
    super.code,
  });

  @override
  bool get isRetryable => false;
}
