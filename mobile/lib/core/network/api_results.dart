/// Sealed hierarchy representing either a successful API operation or an error result.
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccessResult<T>;
  const factory ApiResult.failure(
    String message, {
    String? code,
    int? statusCode,
  }) = ApiErrorResult<T>;

  bool get isSuccess => this is ApiSuccessResult<T>;
  bool get isFailure => this is ApiErrorResult<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccessResult<T>(data: final data) => data,
        ApiErrorResult<T>() => null,
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

/// Failure result holding error [message], optional server error [code], and HTTP [statusCode].
final class ApiErrorResult<T> extends ApiResult<T> {
  final String message;
  final String? code;
  final int? statusCode;

  const ApiErrorResult(
    this.message, {
    this.code,
    this.statusCode,
  });

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
