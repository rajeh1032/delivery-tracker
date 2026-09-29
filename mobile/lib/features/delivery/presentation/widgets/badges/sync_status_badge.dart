import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/utils/enums.dart';

/// Interactive offline-first synchronization badge with states for syncing,
/// waiting, synced, and retryable failed state.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    super.key,
    required this.syncStatus,
    this.onRetry,
  });

  final SyncStatus syncStatus;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final (label, fgColor, bgColor, iconWidget) = switch (syncStatus) {
      SyncStatus.synced => (
          context.tr.syncStatusSynced,
          AppColors.synced,
          AppColors.syncedBg,
          const Icon(Icons.cloud_done_rounded, size: 13, color: AppColors.synced),
        ),
      SyncStatus.waitingToSync => (
          context.tr.syncStatusWaitingToSync,
          AppColors.waitingToSync,
          AppColors.waitingToSyncBg,
          const Icon(
            Icons.hourglass_top_rounded,
            size: 13,
            color: AppColors.waitingToSync,
          ),
        ),
      SyncStatus.syncing => (
          context.tr.syncStatusSyncing,
          AppColors.syncing,
          AppColors.syncingBg,
          const SizedBox(
            width: 11,
            height: 11,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.syncing),
            ),
          ),
        ),
      SyncStatus.failed => (
          context.tr.syncStatusFailedToSync,
          AppColors.syncFailed,
          AppColors.syncFailedBg,
          const Icon(
            Icons.refresh_rounded,
            size: 13,
            color: AppColors.syncFailed,
          ),
        ),
    };

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: 3.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );

    if (syncStatus == SyncStatus.failed && onRetry != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          onTap: onRetry,
          child: content,
        ),
      );
    }

    return content;
  }
}
