import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../network/network_constants.dart';

/// Service responsible for real-time connection status monitoring and active reachability validation.
@lazySingleton
class ConnectivityService {
  final InternetConnection _internetConnection;
  final Dio _dio;

  ConnectivityService(
    this._internetConnection,
    this._dio,
  );

  /// Reactive stream notifying connectivity state changes after active reachability verification.
  Stream<bool> get onConnectivityChanged {
    return _internetConnection.onStatusChange
        .asyncMap((status) async {
          if (status == InternetStatus.connected) {
            return await checkReachability();
          }
          return false;
        })
        .distinct();
  }

  /// Current connectivity status with active reachability probe.
  Future<bool> get isConnected => checkInternet();

  /// Performs an initial physical check followed by an active reachability probe to the backend.
  Future<bool> checkInternet() async {
    final bool hasPhysicalConnection =
        await _internetConnection.hasInternetAccess;
    if (!hasPhysicalConnection) return false;
    return await checkReachability();
  }

  /// Sends a lightweight HTTP request with a strict timeout to confirm backend reachability.
  Future<bool> checkReachability() async {
    try {
      final String probeUrl =
          '${NetworkConstants.baseUrl}${NetworkConstants.deliveries}';
      final response = await _dio
          .get(
            probeUrl,
            options: Options(
              sendTimeout: NetworkConstants.reachabilityTimeout,
              receiveTimeout: NetworkConstants.reachabilityTimeout,
              validateStatus: (status) => status != null,
            ),
          )
          .timeout(NetworkConstants.reachabilityTimeout);
      return response.statusCode != null;
    } catch (_) {
      return false;
    }
  }

}
