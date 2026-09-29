import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/language_interceptor.dart';
import 'network_constants.dart';

/// Module registering third-party external dependencies into the service locator.
@module
abstract class ExternalModules {
  @lazySingleton
  Dio provideDio(
    PrettyDioLogger prettyDioLogger,
    LanguageInterceptor languageInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: NetworkConstants.baseUrl,
        headers: {
          NetworkConstants.headerContentType: NetworkConstants.contentTypeJson,
        },
        connectTimeout: NetworkConstants.connectTimeout,
        receiveTimeout: NetworkConstants.receiveTimeout,
        sendTimeout: NetworkConstants.sendTimeout,
      ),
    );
    dio.interceptors.addAll([
      languageInterceptor,
      prettyDioLogger,
    ]);

    return dio;
  }

  @lazySingleton
  PrettyDioLogger providePrettyDioLogger() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    );
  }

  @preResolve
  Future<SharedPreferences> get provideSharedPreferences async =>
      await SharedPreferences.getInstance();

  @lazySingleton
  InternetConnection provideInternetConnection() => InternetConnection();

  @lazySingleton
  Uuid provideUuid() => const Uuid();

  @lazySingleton
  ImagePicker provideImagePicker() => ImagePicker();
}
