import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'delivery_address_row.dart';
import 'delivery_card_footer.dart';
import 'delivery_card_header.dart';

/// Complete responsive delivery order card ported from Masar driver architecture.
class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.onRetrySync,
  });

  final DeliveryEntity delivery;
  final VoidCallback? onTap;
  final VoidCallback? onRetrySync;

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeliveryCardHeader(
            customerName: delivery.customerName,
            orderNumber: delivery.orderNumber,
            amountDue: delivery.amountDue,
            paymentMethod: delivery.paymentMethod,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          DeliveryAddressRow(address: delivery.address),
          const SizedBox(height: AppDimensions.spaceMD),
          DeliveryCardFooter(
            customerPhone: delivery.phone,
            deliveryStatus: delivery.status,
            syncStatus: delivery.syncStatus,
            onRetrySync: onRetrySync,
          ),
        ],
      ),
    );

    final cardDecoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

    final borderRadius = BorderRadius.circular(AppDimensions.radiusXXL);

    if (onTap == null) {
      return Container(
        decoration: cardDecoration,
        child: cardContent,
      );
    }

    return Container(
      decoration: cardDecoration,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: cardContent,
        ),
      ),
    );
  }
}
