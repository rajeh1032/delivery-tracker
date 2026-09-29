/// Network configuration constants, endpoints, and timeouts.
abstract final class NetworkConstants {
  /// Base API URL configurable dynamically at build/run time via:
  /// `--dart-define=BASE_URL=http://...`
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  // Endpoints
  static const String deliveries = '/deliveries';
  static String deliveryById(int id) => '/deliveries/$id';
  static String completeDelivery(int id) => '/deliveries/$id/complete';
  static String failDelivery(int id) => '/deliveries/$id/fail';
  static String uploadProof(int id) => '/deliveries/$id/proof';

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';
}

/// Global convenience constant for quick access matching plan specification.
const String kBaseUrl = NetworkConstants.baseUrl;
