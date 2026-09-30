import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/core/components/shimmer_box.dart';

/// Shimmer skeleton loader matching the delivery details screen layout rhythm.
class DeliveryDetailsSkeleton extends StatelessWidget {
  const DeliveryDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShimmerBox(
          width: double.infinity,
          height: AppDimensions.mapHeaderHeight,
          borderRadius: BorderRadius.zero,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceSM),
                const Row(
                  children: [
                    ShimmerBox(
                      width: 80,
                      height: 26,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusFull),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spaceSM),
                    ShimmerBox(
                      width: 100,
                      height: 26,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusFull),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceLG),
                const ShimmerBox(
                  width: double.infinity,
                  height: 100,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusXXL),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMD),
                const ShimmerBox(
                  width: double.infinity,
                  height: 90,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusXXL),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMD),
                const ShimmerBox(
                  width: double.infinity,
                  height: 80,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusXXL),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
