/// Network configuration constants, endpoints, timeouts, and error codes.
abstract final class NetworkConstants {
  /// Override with `--dart-define=BASE_URL=http://...` for a local API.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://alshamel-delivery-api.vercel.app',
  );

  // Endpoints & Path Formats
  static const String deliveries = '/deliveries';
  static String deliveryById(int id) => '/deliveries/$id';
  static String completeDelivery(int id) => '/deliveries/$id/complete';
  static String failDelivery(int id) => '/deliveries/$id/fail';
  static String uploadProof(int id) => '/deliveries/$id/proof';

  // Retrofit Path Templates
  static const String pathDeliveries = '/deliveries';
  static const String pathDeliveryById = '/deliveries/{id}';
  static const String pathCompleteDelivery = '/deliveries/{id}/complete';
  static const String pathFailDelivery = '/deliveries/{id}/fail';
  static const String pathUploadProof = '/deliveries/{id}/proof';

  // Parameter Names
  static const String paramId = 'id';
  static const String paramPhoto = 'photo';

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  static const Duration reachabilityTimeout = Duration(seconds: 3);

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String contentTypeJson = 'application/json';
  static const String retryAfter = 'retry-after';
  static const String acceptLanguage = 'Accept-Language';
  static const String multipartFormData = 'multipart/form-data';

  // Error & Payload Keys
  static const String keyError = 'error';
  static const String keyMessage = 'message';
  static const String keyCode = 'code';
  static const String keyRecipientName = 'recipient_name';
  static const String keyNote = 'note';
  static const String keyReason = 'reason';
  static const String keyBaseVersion = 'base_version';
  static const String keyClientActionId = 'client_action_id';
  static const String keyUpdatedAt = 'updated_at';
  static const String keyLocalPhotoPath = 'local_photo_path';

  // HTTP Status Codes
  static const int statusConflict = 409;
  static const int statusInternalServerError = 500;

  // Machine-Readable Error Codes
  static const String deliveryNotFound = 'DELIVERY_NOT_FOUND';
  static const String validationError = 'VALIDATION_ERROR';
  static const String idempotencyKeyReuse = 'IDEMPOTENCY_KEY_REUSE';
  static const String deliveryConflict = 'DELIVERY_CONFLICT';
  static const String proofFileMissing = 'PROOF_FILE_MISSING';
  static const String noInternet = 'NO_INTERNET';
  static const String unknownError = 'UNKNOWN_ERROR';
  static const String defaultErrorCode = 'NO_STATUS_CODE';

  // Standard Messages
  static const String connectionTimeoutMessage =
      'Connection timeout with API server.';
  static const String sendTimeoutMessage = 'Send timeout with API server.';
  static const String receiveTimeoutMessage =
      'Receive timeout with API server.';
  static const String badCertificateMessage =
      'Connection to API server failed due to an invalid certificate.';
  static const String cancelMessage =
      'Connection to API was cancelled. Please try again later.';
  static const String connectionErrorMessage =
      'Connection to API server failed due to an internet connection issue.';
  static const String unexpectedErrorMessage =
      'Unexpected error occurred. Please try again later.';
  static const String noResponseMessage = 'No response received from server.';
  static const String resourceNotFoundMessage = 'Resource not found';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String noInternetMessage = 'No internet connection available.';
  static const String deliveryConflictMessage =
      'Delivery has already been finalized';
}

/// Global convenience getter for quick access matching plan specification.
String get kBaseUrl => NetworkConstants.baseUrl;
