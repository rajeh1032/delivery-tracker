import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/core/helpers/phone_launcher_utils.dart';
import '../badges/delivery_status_badge.dart';
import '../badges/sync_status_badge.dart';

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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Tooltip(
        message: context.tr.callCustomer,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          onTap: () => PhoneLauncherUtils.makePhoneCall(
            context: context,
            phoneNumber: customerPhone,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    customerPhone,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                const Icon(
                  Icons.phone_outlined,
                  size: AppDimensions.iconSM,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
      Wrap(
        spacing: AppDimensions.spaceSM,
        runSpacing: AppDimensions.spaceSM,
        children: [
          DeliveryStatusBadge(status: deliveryStatus),
          SyncStatusBadge(syncStatus: syncStatus, onRetry: onRetrySync),
        ],
      ),
    ],
  );
}
