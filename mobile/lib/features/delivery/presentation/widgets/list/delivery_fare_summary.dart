import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/helpers/formatters.dart';
import '../badges/payment_method_badge.dart';

/// Fare and payment method summary on the delivery card.
class DeliveryFareSummary extends StatelessWidget {
  const DeliveryFareSummary({
    super.key,
    required this.amountDue,
    required this.paymentMethod,
    this.isCompact = false,
  });

  final double amountDue;
  final String paymentMethod;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final amountLabel = Formatters.formatAmountDue(amountDue);

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            amountLabel,
            textDirection: TextDirection.ltr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          PaymentMethodBadge(paymentMethod: paymentMethod),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          amountLabel,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        PaymentMethodBadge(paymentMethod: paymentMethod),
      ],
    );
  }
}
