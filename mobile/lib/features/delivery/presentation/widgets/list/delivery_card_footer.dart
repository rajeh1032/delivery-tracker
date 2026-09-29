import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import '../badges/delivery_status_badge.dart';
import '../badges/sync_status_badge.dart';

/// Footer of the delivery card showing phone number and status badges.
class DeliveryCardFooter extends StatelessWidget {
  const DeliveryCardFooter({
    super.key,
    required this.customerPhone,
    required this.deliveryStatus,
    required this.syncStatus,
    this.onRetrySync,
  });

  final String customerPhone;
  final DeliveryStatus deliveryStatus;
  final SyncStatus syncStatus;
  final VoidCallback? onRetrySync;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.phone_outlined,
          size: AppDimensions.iconSM,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spaceXS),
        Text(
          customerPhone,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        DeliveryStatusBadge(status: deliveryStatus),
        const SizedBox(width: AppDimensions.spaceXS),
        SyncStatusBadge(
          syncStatus: syncStatus,
          onRetry: onRetrySync,
        ),
      ],
    );
  }
}
