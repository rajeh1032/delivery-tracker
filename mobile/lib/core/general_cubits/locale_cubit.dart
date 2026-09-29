import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

/// Cubit managing dynamic runtime application language selection (English / Arabic)
/// and persisting preferences via SharedPreferences.
@lazySingleton
class LocaleCubit extends Cubit<LocaleState> {
  static const String _kLanguageKey = 'selected_language_code';

  LocaleCubit() : super(const LocaleState(Locale('en'))) {
    loadSavedLocale();
  }

  /// Loads previously selected language preference from local storage.
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kLanguageKey);
      if (code != null && (code == 'ar' || code == 'en')) {
        emit(LocaleState(Locale(code)));
      }
    } catch (_) {
      // Fallback to default English locale if disk read fails
    }
  }

  /// Updates the application locale and persists the selection.
  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'ar') return;
    emit(LocaleState(locale));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguageKey, locale.languageCode);
    } catch (_) {
      // Non-fatal if storage persistence fails
    }
  }

  /// Toggles between English and Arabic.
  Future<void> toggleLocale() async {
    final nextCode = state.locale.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(Locale(nextCode));
  }
}
