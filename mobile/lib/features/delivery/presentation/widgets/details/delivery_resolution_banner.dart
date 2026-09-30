import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/trailing_icon_label.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

class DeliveryResolutionBanner extends StatelessWidget {
  const DeliveryResolutionBanner({super.key, required this.delivered});
  final bool delivered;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppDimensions.spaceMD),
    child: TrailingIconLabel(
      label: delivered
          ? context.tr.deliveredOrderBanner
          : context.tr.failedOrderBanner,
      icon: Icon(
        delivered ? Icons.check_circle_outline : Icons.info_outline,
        color: delivered ? AppColors.synced : AppColors.failed,
        size: 20,
      ),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
    ),
  );
}
