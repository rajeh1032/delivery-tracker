import 'package:delivery_tracker/core/database/local_storage_service.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:flutter_test/flutter_test.dart';
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

    test('configureDependencies registers LocalStorageService as lazy singleton', () async {
      expect(getIt.isRegistered<LocalStorageService>(), isFalse);

      await configureDependencies();

      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
    });

    test('configureDependencies registers DeliveryLocalDataSource as factory', () async {
      expect(getIt.isRegistered<DeliveryLocalDataSource>(), isFalse);

      await configureDependencies();

      expect(getIt.isRegistered<DeliveryLocalDataSource>(), isTrue);
    });
  });
}
