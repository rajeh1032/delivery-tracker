import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/shimmer_box.dart';

/// Shimmer placeholder card representing a loading delivery item.
class DeliveryCardSkeleton extends StatelessWidget {
  const DeliveryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(
                width: 34,
                height: 34,
                borderRadius: BorderRadius.all(Radius.circular(17)),
              ),
              SizedBox(width: AppDimensions.spaceSM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 110, height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: 70, height: 12),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerBox(width: 80, height: 16),
                  SizedBox(height: 6),
                  ShimmerBox(width: 55, height: 12),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          Row(
            children: [
              ShimmerBox(
                width: 18,
                height: 18,
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
              SizedBox(width: AppDimensions.spaceSM),
              Expanded(
                child: ShimmerBox(width: double.infinity, height: 14),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMD),
          Row(
            children: [
              ShimmerBox(width: 90, height: 14),
              Spacer(),
              ShimmerBox(width: 65, height: 20),
              SizedBox(width: AppDimensions.spaceXS),
              ShimmerBox(width: 65, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
