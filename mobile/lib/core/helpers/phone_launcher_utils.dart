import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../extensions/context_extensions.dart';
import 'snackbar_utils.dart';

/// Cross-platform telephone dialer utility with fallback handling for simulators.
abstract final class PhoneLauncherUtils {
  /// Opens device native phone dialer with provided phone number.
  /// Falls back to clipboard copy if phone dialing cannot be handled (e.g. simulator).
  static Future<bool> makePhoneCall({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        SnackBarUtils.showWarning(context, context.tr.phoneInvalid);
      }
      return false;
    }

    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      }
    } catch (_) {
      // Fallback below
    }

    // Fallback for simulators or devices without telephony
    await Clipboard.setData(ClipboardData(text: cleanPhone));
    if (context.mounted) {
      SnackBarUtils.showInfo(
        context,
        '${context.tr.phoneCopied}: $cleanPhone',
      );
    }
    return false;
  }
}
