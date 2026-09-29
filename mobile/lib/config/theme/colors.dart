import 'package:flutter/material.dart';

/// Semantic color palette optimized for high-glare outdoor delivery environments.
abstract final class AppColors {
  // Brand & Accent Colors (done_app Dark Red & Black)
  static const Color primary = Color(0xFF911D05);
  static const Color primaryLight = Color(0xFFB52B10);
  static const Color primaryDark = Color(0xFF6B1503);
  static const Color buttonDark = Color(0xFF1C1C1C);

  static const Color secondary = Color(0xFFDC6E2E);
  static const Color secondaryLight = Color(0xFFFFA726);
  static const Color secondaryDark = Color(0xFFB34A1B);

  // Surface & Neutral Colors (Clean White Theme)
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F7F7);

  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF9E9E9E);

  static const Color border = Color(0xFFEBEBEB);
  static const Color divider = Color(0xFFF0F0F0);

  // Synchronization Status Colors (Offline-First Pipeline)
  static const Color synced = Color(0xFF12B76A);
  static const Color syncedBg = Color(0xFFEBF5ED);

  static const Color waitingToSync = Color(0xFFDC6E2E);
  static const Color waitingToSyncBg = Color(0xFFFFF4EC);

  static const Color syncing = Color(0xFF2196F3);
  static const Color syncingBg = Color(0xFFE3F2FD);

  static const Color syncFailed = Color(0xFFD32F2F);
  static const Color syncFailedBg = Color(0xFFFDE8E8);

  // Order Delivery Status Colors
  static const Color pending = Color(0xFF911D05);
  static const Color pendingBg = Color(0xFFFDEAE7);

  static const Color delivered = Color(0xFF12B76A);
  static const Color deliveredBg = Color(0xFFEBF5ED);

  static const Color failed = Color(0xFFD32F2F);
  static const Color failedBg = Color(0xFFFDE8E8);

  // Shimmer / Placeholder
  static const Color shimmerBase = Color(0xFFEEEEEE);
  static const Color shimmerHighlight = Color(0xFFFBFBFB);

  // Radar, Map & Overlay Semantics
  static const Color mapBackdrop = Color(0xFFFAFAFA);
  static const Color radarSweep = Color(0x33911D05);
  static const Color barrier = Color(0x66000000);
  static const Color shadowSoft = Color(0x0F000000);
  static const Color pickupColor = Color(0xFF911D05);
  static const Color metricText = Color(0xFF424242);
  static const Color metricIcon = Color(0xFF6B6B6B);
}
