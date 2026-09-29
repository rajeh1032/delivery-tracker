import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_state.dart';

/// Premium segmented pill tab bar ported from done_app trips selector.
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
    final tabs = [
      (DeliveryStatusFilter.all, '${context.tr.filterAll} ($totalCount)'),
      (DeliveryStatusFilter.pending, '${context.tr.filterPending} ($pendingCount)'),
      (DeliveryStatusFilter.delivered, '${context.tr.filterDelivered} ($deliveredCount)'),
      (DeliveryStatusFilter.failed, '${context.tr.filterFailed} ($failedCount)'),
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: tabs.map((item) {
          final filter = item.$1;
          final label = item.$2;
          final isSelected = selectedFilter == filter;

          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterSelected(filter),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

