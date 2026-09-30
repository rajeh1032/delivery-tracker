import 'package:flutter/material.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/theme/app_theme_extension.dart';
import '../l10n/generated/app_localizations.dart';

/// Context extension for concise access to localization, theme, and geometry.
extension BuildContextX on BuildContext {
  /// Localized strings getter.
  AppLocalizations get tr => AppLocalizations.of(this);

  /// Semantic theme colors extension getter.
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;

  /// Custom typography theme extension getter.
  AppTextStyles get textStyles =>
      Theme.of(this).extension<AppTextStyles>() ?? AppTextStyles.light;

  /// Returns whether current text direction is Right-to-Left (e.g. Arabic).
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Viewport width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Viewport height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Safe area bottom padding.
  double get safeBottom => MediaQuery.paddingOf(this).bottom;
}
