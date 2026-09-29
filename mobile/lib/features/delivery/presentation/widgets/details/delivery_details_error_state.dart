import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/custom_elevated_button.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// State displayed when loading delivery details fails.
class DeliveryDetailsErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const DeliveryDetailsErrorState({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.failed,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(
                errorMessage ?? context.tr.errorLoadDeliveries,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              SizedBox(
                width: 160,
                child: CustomElevatedButton(
                  text: context.tr.retry,
                  onPressed: onRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
