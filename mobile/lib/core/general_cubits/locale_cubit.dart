import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'locale_state.dart';

/// Cubit managing dynamic runtime application language selection (English / Arabic)
/// and persisting preferences via SharedPreferences.
@lazySingleton
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(Locale(AppConstants.defaultLanguage))) {
    loadSavedLocale();
  }

  /// Loads previously selected language preference from local storage.
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(AppConstants.languageCode);
      if (code != null &&
          (code == AppConstants.arabicLanguage ||
              code == AppConstants.englishLanguage)) {
        emit(LocaleState(Locale(code)));
      }
    } catch (_) {
      // Fallback to default English locale if disk read fails
    }
  }

  /// Updates the application locale and persists the selection.
  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != AppConstants.englishLanguage &&
        locale.languageCode != AppConstants.arabicLanguage) {
      return;
    }
    emit(LocaleState(locale));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageCode, locale.languageCode);
    } catch (_) {
      // Non-fatal if storage persistence fails
    }
  }

  /// Toggles between English and Arabic.
  Future<void> toggleLocale() async {
    final nextCode = state.locale.languageCode == AppConstants.arabicLanguage
        ? AppConstants.englishLanguage
        : AppConstants.arabicLanguage;
    await setLocale(Locale(nextCode));
  }
}

