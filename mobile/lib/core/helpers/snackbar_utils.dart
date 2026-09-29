import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/colors.dart';
import 'app_snackbar_card.dart';
import 'snackbar_animated_icon.dart';

/// Centralized SnackBar utilities modeled after done_app snackbar design.
abstract final class SnackBarUtils {
  /// Shows a success snackbar with green accent and subtle pop animation.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    _showSnackBar(
      context,
      message: message,
      accentColor: AppColors.synced,
      icon: Icons.check_rounded,
      variant: SnackbarVariant.success,
      duration: duration,
    );
  }

  /// Shows an error snackbar with brand red accent and subtle shake animation.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackBar(
      context,
      message: message,
      accentColor: AppColors.primary,
      icon: Icons.close_rounded,
      variant: SnackbarVariant.error,
      duration: duration,
    );
  }

  /// Shows a warning snackbar with amber accent.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message: message,
      accentColor: const Color(0xFFFFA726),
      icon: Icons.priority_high_rounded,
      variant: SnackbarVariant.warning,
      duration: duration,
    );
  }

  /// Shows an informative snackbar with blue accent.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message: message,
      accentColor: const Color(0xFF2196F3),
      icon: Icons.info_outline_rounded,
      variant: SnackbarVariant.info,
      duration: duration,
    );
  }

  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color accentColor,
    required IconData icon,
    required SnackbarVariant variant,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: AppSnackbarCard(
          message: message,
          accentColor: accentColor,
          icon: icon,
          variant: variant,
          onDismiss: messenger.hideCurrentSnackBar,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceMD,
        ),
        padding: EdgeInsets.zero,
        duration: duration,
      ),
    );
  }
}
