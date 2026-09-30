import 'package:dio/dio.dart';
import 'package:delivery_tracker/core/helpers/shared_pref.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/services/language_interceptor.dart';
import 'package:delivery_tracker/core/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSharedPrefHelper extends Mock implements SharedPrefHelper {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

void main() {
  late MockSharedPrefHelper mockSharedPrefHelper;
  late LanguageInterceptor interceptor;
  late MockRequestInterceptorHandler mockHandler;

  setUp(() {
    mockSharedPrefHelper = MockSharedPrefHelper();
    interceptor = LanguageInterceptor(mockSharedPrefHelper);
    mockHandler = MockRequestInterceptorHandler();
  });

  group('LanguageInterceptor', () {
    test('injects stored language code into Accept-Language header', () {
      when(() => mockSharedPrefHelper.getData(key: AppConstants.languageCode))
          .thenReturn(AppConstants.arabicLanguage);

      final options = RequestOptions(path: '/test');
      interceptor.onRequest(options, mockHandler);

      expect(
        options.headers[NetworkConstants.acceptLanguage],
        AppConstants.arabicLanguage,
      );
      verify(() => mockHandler.next(options)).called(1);
    });

    test('falls back to default language when no preference is saved', () {
      when(() => mockSharedPrefHelper.getData(key: AppConstants.languageCode))
          .thenReturn(null);

      final options = RequestOptions(path: '/test');
      interceptor.onRequest(options, mockHandler);

      expect(
        options.headers[NetworkConstants.acceptLanguage],
        AppConstants.defaultLanguage,
      );
      verify(() => mockHandler.next(options)).called(1);
    });

    test('falls back to default language when saved value is empty string', () {
      when(() => mockSharedPrefHelper.getData(key: AppConstants.languageCode))
          .thenReturn('');

      final options = RequestOptions(path: '/test');
      interceptor.onRequest(options, mockHandler);

      expect(
        options.headers[NetworkConstants.acceptLanguage],
        AppConstants.defaultLanguage,
      );
      verify(() => mockHandler.next(options)).called(1);
    });
  });
}
