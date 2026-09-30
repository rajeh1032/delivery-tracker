import 'package:flutter/material.dart';
import 'package:delivery_tracker/core/components/trailing_icon_label.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/utils/enums.dart';

/// Semantic status badge representing the delivery lifecycle state.
class DeliveryStatusBadge extends StatelessWidget {
  const DeliveryStatusBadge({super.key, required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, fgColor, bgColor, icon) = switch (status) {
      DeliveryStatus.pending => (
        context.tr.deliveryStatusPending,
        AppColors.pending,
        AppColors.pendingBg,
        Icons.schedule_rounded,
      ),
      DeliveryStatus.delivered => (
        context.tr.deliveryStatusDelivered,
        AppColors.delivered,
        AppColors.deliveredBg,
        Icons.check_circle_rounded,
      ),
      DeliveryStatus.failed => (
        context.tr.deliveryStatusFailed,
        AppColors.failed,
        AppColors.failedBg,
        Icons.cancel_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: 3.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: TrailingIconLabel(
        label: label,
        icon: Icon(icon, size: 14, color: fgColor),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fgColor,
        ),
      ),
    );
  }
}
