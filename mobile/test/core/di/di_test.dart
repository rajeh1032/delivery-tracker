import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
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
  });
}
