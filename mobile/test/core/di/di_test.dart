import 'package:dio/dio.dart';
import 'package:delivery_tracker/core/database/local_storage_service.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:delivery_tracker/core/helpers/shared_pref.dart';
import 'package:delivery_tracker/core/network/api_services.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/core/services/language_interceptor.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dependency Injection', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await getIt.reset();
    });

    test('configureDependencies registers LocaleCubit as singleton', () async {
      expect(getIt.isRegistered<LocaleCubit>(), isFalse);

      await configureDependencies();

      expect(getIt.isRegistered<LocaleCubit>(), isTrue);
      final cubit1 = getIt<LocaleCubit>();
      final cubit2 = getIt<LocaleCubit>();

      expect(identical(cubit1, cubit2), isTrue);
    });

    test(
        'configureDependencies registers LocalStorageService as lazy singleton',
        () async {
      expect(getIt.isRegistered<LocalStorageService>(), isFalse);

      await configureDependencies();

      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
    });

    test('configureDependencies registers DeliveryLocalDataSource as factory',
        () async {
      expect(getIt.isRegistered<DeliveryLocalDataSource>(), isFalse);

      await configureDependencies();

      expect(getIt.isRegistered<DeliveryLocalDataSource>(), isTrue);
    });

    test('configureDependencies registers external modules and network stack',
        () async {
      await configureDependencies();

      expect(getIt.isRegistered<SharedPreferences>(), isTrue);
      expect(getIt.isRegistered<SharedPrefHelper>(), isTrue);
      expect(getIt.isRegistered<PrettyDioLogger>(), isTrue);
      expect(getIt.isRegistered<InternetConnection>(), isTrue);
      expect(getIt.isRegistered<LanguageInterceptor>(), isTrue);
      expect(getIt.isRegistered<Dio>(), isTrue);
      expect(getIt.isRegistered<ConnectivityService>(), isTrue);
      expect(getIt.isRegistered<ApiServices>(), isTrue);
      expect(getIt.isRegistered<DeliveryRemoteDs>(), isTrue);

      final dio = getIt<Dio>();
      expect(dio.interceptors.whereType<LanguageInterceptor>().length, 1);
      expect(dio.interceptors.whereType<PrettyDioLogger>().length, 1);
      final langIndex =
          dio.interceptors.indexWhere((i) => i is LanguageInterceptor);
      final loggerIndex =
          dio.interceptors.indexWhere((i) => i is PrettyDioLogger);
      expect(langIndex, lessThan(loggerIndex));
    });

  });
}
