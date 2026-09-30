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
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  orderNumber,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
