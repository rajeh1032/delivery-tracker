import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/pill_button.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Sticky bottom button allowing the courier to trigger a full queue synchronization retry.
class SyncQueueRetryAllButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetryAll;

  const SyncQueueRetryAllButton({
    super.key,
    required this.isLoading,
    required this.onRetryAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: PillButton(
          text: context.tr.retryAll,
          isLoading: isLoading,
          backgroundColor: AppColors.primary,
          icon: const Icon(
            Icons.sync_rounded,
            size: AppDimensions.iconMD,
            color: Colors.white,
          ),
          onPressed: onRetryAll,
        ),
      ),
    );
  }
}
