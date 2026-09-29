import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/sync_queue/sync_queue_state.dart';

/// Clean empty state message displayed when a sync queue tab has no entries.
class SyncQueueEmptyState extends StatelessWidget {
  final SyncQueueTab tab;

  const SyncQueueEmptyState({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final isPending = tab == SyncQueueTab.pending;
    final message = isPending
        ? context.tr.emptyPendingQueue
        : context.tr.emptyFailedQueue;
    final iconData =
        isPending ? Icons.check_circle_outline_rounded : Icons.thumb_up_alt_outlined;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: AppDimensions.iconLG,
                color: AppColors.synced,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
