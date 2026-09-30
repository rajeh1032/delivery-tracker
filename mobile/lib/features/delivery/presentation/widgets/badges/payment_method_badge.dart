import 'package:flutter/material.dart';
import 'package:delivery_tracker/core/components/trailing_icon_label.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Pill badge displaying the payment method (Cash / InstaPay / Card).
class PaymentMethodBadge extends StatelessWidget {
  const PaymentMethodBadge({super.key, required this.paymentMethod});

  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final isCash = paymentMethod.toLowerCase().trim() == 'cash';
    final label = isCash ? context.tr.paymentCash : context.tr.paymentInstapay;
    final icon = isCash
        ? Icons.payments_outlined
        : Icons.account_balance_wallet_outlined;
    final color = isCash ? AppColors.secondaryDark : AppColors.primary;
    final bgColor = isCash
        ? AppColors.secondaryLight.withValues(alpha: 0.15)
        : AppColors.primaryLight.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: 2.5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: TrailingIconLabel(
        label: label,
        icon: Icon(icon, size: 14, color: color),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
