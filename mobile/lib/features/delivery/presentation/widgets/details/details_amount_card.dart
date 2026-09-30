import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/helpers/formatters.dart';
import '../badges/payment_method_badge.dart';

class DetailsAmountCard extends StatelessWidget {
  const DetailsAmountCard({
    super.key,
    required this.amountDue,
    required this.paymentMethod,
    this.orderNumber,
  });
  final double amountDue;
  final String paymentMethod;
  final String? orderNumber;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppDimensions.spaceLG),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.orderSummary,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (orderNumber != null) ...[
          const SizedBox(height: AppDimensions.spaceXXS),
          Text(
            orderNumber!,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.spaceLG),
        Text(
          context.tr.amountDue,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        Text(
          Formatters.formatAmountDue(amountDue),
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        PaymentMethodBadge(paymentMethod: paymentMethod),
      ],
    ),
  );
}
