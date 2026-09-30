import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/custom_elevated_button.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Error state view with retry action button.
class DeliveriesErrorState extends StatelessWidget {
  const DeliveriesErrorState({
    super.key,
    this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback onRetry;

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
                color: AppColors.failed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: AppColors.failed,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              message ?? context.tr.errorLoadDeliveries,
              textAlign: TextAlign.center,
              style: context.textStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            SizedBox(
              width: 160,
              child: CustomElevatedButton(
                text: context.tr.retry,
                onPressed: onRetry,
                height: AppDimensions.buttonHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
