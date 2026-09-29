import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/app_chip.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/deliveries_list/deliveries_list_state.dart';

/// Horizontally scrollable row of status filter chips with live counts.
class DeliveriesFilterChips extends StatelessWidget {
  const DeliveriesFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.totalCount,
    required this.pendingCount,
    required this.deliveredCount,
    required this.failedCount,
  });

  final DeliveryStatusFilter selectedFilter;
  final ValueChanged<DeliveryStatusFilter> onFilterSelected;
  final int totalCount;
  final int pendingCount;
  final int deliveredCount;
  final int failedCount;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (DeliveryStatusFilter.all, context.tr.filterAll, totalCount, AppColors.primary),
      (DeliveryStatusFilter.pending, context.tr.filterPending, pendingCount, AppColors.pending),
      (DeliveryStatusFilter.delivered, context.tr.filterDelivered, deliveredCount, AppColors.delivered),
      (DeliveryStatusFilter.failed, context.tr.filterFailed, failedCount, AppColors.failed),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
      child: Row(
        children: [
          for (final (filter, label, count, color) in chips) ...[
            AppChip(
              label: label,
              count: count,
              isSelected: selectedFilter == filter,
              activeColor: color,
              onTap: () => onFilterSelected(filter),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
          ],
        ],
      ),
    );
  }
}
