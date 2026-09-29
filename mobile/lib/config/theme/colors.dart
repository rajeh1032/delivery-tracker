import 'package:flutter/material.dart';

/// Semantic color palette optimized for high-glare outdoor delivery environments.
abstract final class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF1E56A0);
  static const Color primaryLight = Color(0xFF2E86DE);
  static const Color primaryDark = Color(0xFF163172);

  static const Color secondary = Color(0xFFFF8E00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFE65100);

  // Surface & Neutral Colors
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEEF2F6);

  // Synchronization Status Colors (Offline-First Pipeline)
  static const Color synced = Color(0xFF16A34A);
  static const Color syncedBg = Color(0xFFDCFCE7);

  static const Color waitingToSync = Color(0xFFD97706);
  static const Color waitingToSyncBg = Color(0xFFFEF3C7);

  static const Color syncing = Color(0xFF0284C7);
  static const Color syncingBg = Color(0xFFE0F2FE);

  static const Color syncFailed = Color(0xFFDC2626);
  static const Color syncFailedBg = Color(0xFFFEE2E2);

  // Order Delivery Status Colors
  static const Color pending = Color(0xFF0284C7);
  static const Color pendingBg = Color(0xFFE0F2FE);

  static const Color delivered = Color(0xFF16A34A);
  static const Color deliveredBg = Color(0xFFDCFCE7);

  static const Color failed = Color(0xFFDC2626);
  static const Color failedBg = Color(0xFFFEE2E2);

  // Shimmer / Placeholder
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Radar, Map & Overlay Semantics
  static const Color mapBackdrop = Color(0xFFF1F5F9);
  static const Color radarSweep = Color(0x401E56A0);
  static const Color barrier = Color(0x66000000);
  static const Color shadowSoft = Color(0x0F000000);
  static const Color pickupColor = Color(0xFF2563EB);
  static const Color metricText = Color(0xFF475569);
  static const Color metricIcon = Color(0xFF64748B);
}
