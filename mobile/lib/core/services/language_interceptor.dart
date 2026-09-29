import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../helpers/shared_pref.dart';
import '../network/network_constants.dart';
import '../utils/constants.dart';

/// Interceptor that attaches the user's preferred language code to outgoing HTTP requests.
@lazySingleton
class LanguageInterceptor extends Interceptor {
  final SharedPrefHelper sharedPrefHelper;

  LanguageInterceptor(this.sharedPrefHelper);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final dynamic savedLang =
        sharedPrefHelper.getData(key: AppConstants.languageCode);
    final String langCode =
        (savedLang is String && savedLang.isNotEmpty)
            ? savedLang
            : AppConstants.defaultLanguage;

    options.headers[NetworkConstants.acceptLanguage] = langCode;
    handler.next(options);
  }
}
