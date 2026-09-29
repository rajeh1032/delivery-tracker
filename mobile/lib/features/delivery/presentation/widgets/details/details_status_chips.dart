import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/badges/delivery_status_badge.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/badges/sync_status_badge.dart';

/// Row displaying current delivery status badge and offline sync badge.
class DetailsStatusChips extends StatelessWidget {
  final DeliveryStatus deliveryStatus;
  final SyncStatus syncStatus;
  final VoidCallback? onRetrySync;

  const DetailsStatusChips({
    super.key,
    required this.deliveryStatus,
    required this.syncStatus,
    this.onRetrySync,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spaceSM,
      runSpacing: AppDimensions.spaceXS,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DeliveryStatusBadge(status: deliveryStatus),
        SyncStatusBadge(
          syncStatus: syncStatus,
          onRetry: onRetrySync,
        ),
      ],
    );
  }
}
