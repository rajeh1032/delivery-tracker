import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';

/// Customer summary header row with customer initial avatar, name, and order number chip.
class DeliveryCustomerSummary extends StatelessWidget {
  const DeliveryCustomerSummary({
    super.key,
    required this.customerName,
    required this.orderNumber,
  });

  final String customerName;
  final String orderNumber;

  @override
  Widget build(BuildContext context) {
    final initial = customerName.trim().isNotEmpty
        ? customerName.trim().characters.first.toUpperCase()
        : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.surfaceVariant,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                orderNumber,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
