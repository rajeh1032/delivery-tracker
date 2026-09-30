import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state defaults to English locale', () {
      final cubit = LocaleCubit();
      expect(cubit.state.locale, const Locale('en'));
      expect(cubit.state.isEnglish, isTrue);
      expect(cubit.state.isArabic, isFalse);
    });

    test('loads saved Arabic locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'selected_language_code': 'ar',
      });

      final cubit = LocaleCubit();
      await cubit.loadSavedLocale();

      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.isArabic, isTrue);
    });

    test('setLocale emits new locale and saves to SharedPreferences', () async {
      final cubit = LocaleCubit();
      await cubit.setLocale(const Locale('ar'));

      expect(cubit.state.locale, const Locale('ar'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language_code'), 'ar');
    });

    test('toggleLocale switches back and forth between en and ar', () async {
      final cubit = LocaleCubit();
      expect(cubit.state.locale, const Locale('en'));

      await cubit.toggleLocale();
      expect(cubit.state.locale, const Locale('ar'));

      await cubit.toggleLocale();
      expect(cubit.state.locale, const Locale('en'));
    });
  });
}
