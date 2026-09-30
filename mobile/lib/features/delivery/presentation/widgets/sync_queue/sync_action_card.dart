import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/badges/sync_status_badge.dart';

/// Presentation card representing a single offline mutation queued for background synchronization.
class SyncActionCard extends StatelessWidget {
  final DeliveryAction action;
  final bool isRetrying;
  final VoidCallback? onRetry;

  const SyncActionCard({
    super.key,
    required this.action,
    this.isRetrying = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = action.type == DeliveryActionType.complete;
    final typeColor = isComplete ? AppColors.synced : AppColors.failed;
    final typeIcon =
        isComplete ? Icons.check_circle_outline : Icons.highlight_off;
    final actionTitle =
        isComplete ? context.tr.actionTypeComplete : context.tr.actionTypeFail;

    final recipientName =
        action.payload[NetworkConstants.keyRecipientName]?.toString();
    final reason = action.payload[NetworkConstants.keyReason]?.toString();
    final note = action.payload[NetworkConstants.keyNote]?.toString();
    final hasPhoto =
        action.payload[NetworkConstants.keyLocalPhotoPath] != null &&
            action.payload[NetworkConstants.keyLocalPhotoPath].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceXS,
      ),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: action.status == SyncStatus.failed
              ? AppColors.syncFailed.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceXS),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(typeIcon, color: typeColor, size: 18),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              Expanded(
                child: Text(
                  '$actionTitle · ${context.tr.orderPrefix}${action.deliveryId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SyncStatusBadge(
                syncStatus: action.status,
                onRetry: isRetrying ? null : onRetry,
              ),
            ],
          ),
          if (recipientName != null || reason != null || note != null || hasPhoto) ...[
            const SizedBox(height: AppDimensions.spaceSM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceSM),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipientName != null)
                    Text(
                      '${context.tr.deliveredBy}: $recipientName',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  if (reason != null)
                    Text(
                      '${context.tr.failureReasonLabel}: $reason',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.failed,
                      ),
                    ),
                  if (note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      note,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (hasPhoto) ...[
                    const SizedBox(height: AppDimensions.spaceXXS),
                    Row(
                      children: [
                        const Icon(
                          Icons.photo_camera_back_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr.photoTitle,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (action.lastError != null || action.retryCount > 0) ...[
            const SizedBox(height: AppDimensions.spaceSM),
            Row(
              children: [
                if (action.lastError != null)
                  Expanded(
                    child: Text(
                      action.lastError!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.failed,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (action.retryCount > 0) ...[
                  const SizedBox(width: AppDimensions.spaceSM),
                  Text(
                    '${context.tr.retries}: ${action.retryCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
