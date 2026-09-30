import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/app_back_button.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

class DetailsMapHeader extends StatelessWidget {
  const DetailsMapHeader({super.key, required this.orderNumber, this.onBack});
  final String orderNumber;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppDimensions.spaceXS,
          end: AppDimensions.spaceLG,
          top: AppDimensions.spaceXS,
          bottom: AppDimensions.spaceXS,
        ),
        child: Row(
          children: [
            AppBackButton(onPressed: onBack),
            const SizedBox(width: AppDimensions.spaceSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr.detailsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXXS),
                  Text(
                    orderNumber,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
