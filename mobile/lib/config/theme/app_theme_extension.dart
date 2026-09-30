import 'package:flutter/material.dart';
import 'colors.dart';

/// Semantic colors theme extension providing outdoor high-contrast tokens.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color pickupColor;
  final Color mapBackdrop;
  final Color radarSweep;
  final Color barrier;
  final Color shadowSoft;
  final Color metricText;
  final Color metricIcon;
  final Color cardBackground;
  final Color dividerColor;

  const AppThemeColors({
    required this.pickupColor,
    required this.mapBackdrop,
    required this.radarSweep,
    required this.barrier,
    required this.shadowSoft,
    required this.metricText,
    required this.metricIcon,
    required this.cardBackground,
    required this.dividerColor,
  });

  static const AppThemeColors light = AppThemeColors(
    pickupColor: AppColors.pickupColor,
    mapBackdrop: AppColors.mapBackdrop,
    radarSweep: AppColors.radarSweep,
    barrier: AppColors.barrier,
    shadowSoft: AppColors.shadowSoft,
    metricText: AppColors.metricText,
    metricIcon: AppColors.metricIcon,
    cardBackground: AppColors.surface,
    dividerColor: AppColors.divider,
  );

  @override
  AppThemeColors copyWith({
    Color? pickupColor,
    Color? mapBackdrop,
    Color? radarSweep,
    Color? barrier,
    Color? shadowSoft,
    Color? metricText,
    Color? metricIcon,
    Color? cardBackground,
    Color? dividerColor,
  }) {
    return AppThemeColors(
      pickupColor: pickupColor ?? this.pickupColor,
      mapBackdrop: mapBackdrop ?? this.mapBackdrop,
      radarSweep: radarSweep ?? this.radarSweep,
      barrier: barrier ?? this.barrier,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      metricText: metricText ?? this.metricText,
      metricIcon: metricIcon ?? this.metricIcon,
      cardBackground: cardBackground ?? this.cardBackground,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      pickupColor: Color.lerp(pickupColor, other.pickupColor, t)!,
      mapBackdrop: Color.lerp(mapBackdrop, other.mapBackdrop, t)!,
      radarSweep: Color.lerp(radarSweep, other.radarSweep, t)!,
      barrier: Color.lerp(barrier, other.barrier, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
      metricText: Color.lerp(metricText, other.metricText, t)!,
      metricIcon: Color.lerp(metricIcon, other.metricIcon, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
    );
  }
}
