import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/pill_button.dart';
import 'package:delivery_tracker/core/components/trailing_icon_label.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/extensions/delivery_ui_extensions.dart';
import 'delivery_resolution_banner.dart';

class DetailsActionsBar extends StatelessWidget {
  const DetailsActionsBar({
    super.key,
    required this.delivery,
    this.onMarkDelivered,
    this.onMarkFailed,
  });
  final DeliveryEntity delivery;
  final VoidCallback? onMarkDelivered;
  final VoidCallback? onMarkFailed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppDimensions.spaceLG),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (delivery.isPending) ...[
            if (delivery.isFrozen)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
                child: Text(
                  context.tr.actionsFrozenWhileSync,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppDimensions.buttonHeight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceSM,
                        ),
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                      ),
                      onPressed: delivery.canAct ? onMarkFailed : null,
                      child: TrailingIconLabel(
                        label: context.tr.markFailed,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: PillButton(
                    text: context.tr.markDelivered,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    onPressed: delivery.canAct ? onMarkDelivered : null,
                  ),
                ),
              ],
            ),
          ] else
            DeliveryResolutionBanner(delivered: delivery.isDelivered),
        ],
      ),
    ),
  );
}
