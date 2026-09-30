import 'package:flutter/material.dart';
import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/colors.dart';
import '../../../../../core/extensions/context_extensions.dart';

/// Empty state display when no deliveries are assigned or matching search criteria.
class DeliveriesEmptyState extends StatelessWidget {
  const DeliveriesEmptyState({
    super.key,
    this.isFiltered = false,
  });

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.search_off_rounded : Icons.local_shipping_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              isFiltered
                  ? context.tr.noSearchResults
                  : context.tr.emptyDeliveriesTitle,
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                context.tr.emptyDeliveriesBody,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
