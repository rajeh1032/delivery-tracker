import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/pill_button.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/extensions/delivery_ui_extensions.dart';

/// Sticky bottom actions bar enforcing offline mutation freeze invariants.
class DetailsActionsBar extends StatelessWidget {
  final DeliveryEntity delivery;
  final VoidCallback? onMarkDelivered;
  final VoidCallback? onMarkFailed;

  const DetailsActionsBar({
    super.key,
    required this.delivery,
    this.onMarkDelivered,
    this.onMarkFailed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceMD,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (delivery.isPending) ...[
              if (delivery.isFrozen) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMD,
                    vertical: AppDimensions.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.waitingToSyncBg,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(
                      color: AppColors.waitingToSync.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.sync_problem_rounded,
                        size: AppDimensions.iconSM,
                        color: AppColors.waitingToSync,
                      ),
                      const SizedBox(width: AppDimensions.spaceSM),
                      Expanded(
                        child: Text(
                          context.tr.actionsFrozenWhileSync,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.waitingToSync,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      text: context.tr.markDelivered,
                      icon: const Icon(
                        Icons.check_circle_outline,
                        size: AppDimensions.iconSM,
                        color: Colors.white,
                      ),
                      backgroundColor: AppColors.synced,
                      onPressed: delivery.canAct ? onMarkDelivered : null,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSM),
                  Expanded(
                    child: PillButton(
                      text: context.tr.markFailed,
                      icon: const Icon(
                        Icons.highlight_off,
                        size: AppDimensions.iconSM,
                        color: Colors.white,
                      ),
                      backgroundColor: AppColors.failed,
                      onPressed: delivery.canAct ? onMarkFailed : null,
                    ),
                  ),
                ],
              ),
            ] else if (delivery.isDelivered) ...[
              _ResolutionBanner(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.synced,
                backgroundColor: AppColors.syncedBg,
                message: context.tr.deliveredOrderBanner,
              ),
            ] else if (delivery.isFailed) ...[
              _ResolutionBanner(
                icon: Icons.cancel_rounded,
                iconColor: AppColors.failed,
                backgroundColor: AppColors.failedBg,
                message: context.tr.failedOrderBanner,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResolutionBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String message;

  const _ResolutionBanner({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceMD,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: AppDimensions.iconLG),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
