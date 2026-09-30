import 'package:flutter/material.dart';
import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/colors.dart';
import '../../../domain/entities/delivery_entity.dart';
import 'delivery_card.dart';

/// Scrollable list of delivery cards with pull-to-refresh.
class DeliveriesListView extends StatelessWidget {
  const DeliveriesListView({
    super.key,
    required this.deliveries,
    required this.onRefresh,
    required this.onDeliveryTap,
    this.onRetrySync,
  });

  final List<DeliveryEntity> deliveries;
  final Future<void> Function() onRefresh;
  final ValueChanged<DeliveryEntity> onDeliveryTap;
  final ValueChanged<DeliveryEntity>? onRetrySync;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spaceMD,
          AppDimensions.spaceSM,
          AppDimensions.spaceMD,
          AppDimensions.spaceXL,
        ),
        itemCount: deliveries.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return DeliveryCard(
            key: ValueKey('delivery_card_${delivery.id}'),
            delivery: delivery,
            onTap: () => onDeliveryTap(delivery),
            onRetrySync: onRetrySync != null ? () => onRetrySync!(delivery) : null,
          );
        },
      ),
    );
  }
}
