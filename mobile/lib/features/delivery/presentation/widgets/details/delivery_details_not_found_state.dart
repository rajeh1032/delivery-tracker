import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/app_back_button.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// State displayed when the requested delivery is not found in cache or remote.
class DeliveryDetailsNotFoundState extends StatelessWidget {
  final VoidCallback? onBack;

  const DeliveryDetailsNotFoundState({super.key, this.onBack});

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
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(
                context.tr.deliveryNotFound,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLG),
              AppBackButton(onPressed: onBack ?? () => Navigator.maybePop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
