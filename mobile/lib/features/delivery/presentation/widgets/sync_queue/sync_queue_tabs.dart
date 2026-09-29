import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/sync_queue/sync_queue_state.dart';

/// Segmented tab bar allowing toggle between Pending and Failed sync queues.
class SyncQueueTabs extends StatelessWidget {
  final SyncQueueTab currentTab;
  final int pendingCount;
  final int failedCount;
  final ValueChanged<SyncQueueTab> onTabSelected;

  const SyncQueueTabs({
    super.key,
    required this.currentTab,
    required this.pendingCount,
    required this.failedCount,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceSM,
      ),
      padding: const EdgeInsets.all(AppDimensions.spaceXXS),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: '${context.tr.syncQueuePendingTab} ($pendingCount)',
              isSelected: currentTab == SyncQueueTab.pending,
              onTap: () => onTabSelected(SyncQueueTab.pending),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: '${context.tr.syncQueueFailedTab} ($failedCount)',
              isSelected: currentTab == SyncQueueTab.failed,
              badgeColor: failedCount > 0 ? AppColors.failed : null,
              onTap: () => onTabSelected(SyncQueueTab.failed),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (badgeColor ?? AppColors.primary)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
