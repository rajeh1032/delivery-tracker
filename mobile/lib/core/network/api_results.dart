import 'package:dio/dio.dart';
import 'failures.dart';
import 'network_constants.dart';

/// Sealed hierarchy representing either a successful API operation or an error result.
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccessResult<T>;
  const factory ApiResult.failure(
    String message, {
    String? code,
    int? statusCode,
    Failure? failure,
  }) = ApiErrorResult<T>;

  bool get isSuccess => this is ApiSuccessResult<T>;
  bool get isFailure => this is ApiErrorResult<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccessResult<T>(data: final data) => data,
        ApiErrorResult<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        ApiSuccessResult<T>() => null,
        ApiErrorResult<T>(failure: final failure) => failure,
      };


  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code, int? statusCode) failure,
  }) {
    return switch (this) {
      ApiSuccessResult<T>(data: final data) => success(data),
      ApiErrorResult<T>(
        message: final message,
        code: final code,
        statusCode: final statusCode,
      ) =>
        failure(message, code, statusCode),
    };
  }
}

/// Success result holding unwrapped payload data [data].
final class ApiSuccessResult<T> extends ApiResult<T> {
  final T data;

  const ApiSuccessResult(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiSuccessResult<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'ApiSuccessResult(data: $data)';
}

/// Failure result holding error [message], optional server error [code], HTTP [statusCode],
/// and a strongly-typed [failure].
final class ApiErrorResult<T> extends ApiResult<T> {
  final String message;
  final String? code;
  final int? statusCode;
  final Failure? _rawFailure;

  const ApiErrorResult(
    this.message, {
    this.code,
    this.statusCode,
    Failure? failure,
  }) : _rawFailure = failure;

  /// Underlying domain/data failure.
  Failure get failure =>
      _rawFailure ??
      Failure(
        errorMessage: message,
        code: code ?? NetworkConstants.defaultErrorCode,
      );


  factory ApiErrorResult.fromFailure(
    Failure failure, {
    int? statusCode,
  }) {
    return ApiErrorResult(
      failure.errorMessage,
      code: failure.code,
      statusCode: statusCode,
      failure: failure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiErrorResult<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(message, code, statusCode);

  @override
  String toString() =>
      'ApiErrorResult(message: $message, code: $code, statusCode: $statusCode)';
}

/// Safely executes a remote API network call, catching [DioException] and generic errors
/// and wrapping them into an [ApiResult].
Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
  try {
    final result = await apiCall();
    return ApiSuccessResult<T>(result);
  } on DioException catch (dioError) {
    final failure = ServerFailure.fromDioError(dioException: dioError);
    return ApiErrorResult<T>(
      failure.errorMessage,
      code: failure.code,
      statusCode: dioError.response?.statusCode,
      failure: failure,
    );
  } catch (error) {
    final failure = Failure(
      errorMessage: error.toString(),
      code: NetworkConstants.unknownError,
    );
    return ApiErrorResult<T>(
      failure.errorMessage,
      code: failure.code,
      failure: failure,
    );
  }
}

/// Safely executes a local database call, capturing any unexpected exceptions into an [ApiResult].
Future<ApiResult<T>> safeLocalCall<T>(Future<T> Function() localCall) async {
  try {
    final result = await localCall();
    return ApiSuccessResult<T>(result);
  } catch (error) {
    final failure = Failure(
      errorMessage: error.toString(),
      code: NetworkConstants.unknownError,
    );
    return ApiErrorResult<T>(
      failure.errorMessage,
      code: failure.code,
      failure: failure,
    );
  }
}
