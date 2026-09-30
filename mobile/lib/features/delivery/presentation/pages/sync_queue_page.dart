import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/helpers/snackbar_utils.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/sync_queue/sync_queue_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/sync_queue/sync_queue_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_action_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_queue_empty_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_queue_retry_all_button.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_queue_tabs.dart';

/// Screen displaying queued offline mutation actions with retry operations.
class SyncQueuePage extends StatelessWidget {
  const SyncQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SyncQueueCubit>(
      create: (_) => getIt<SyncQueueCubit>(),
      child: const _SyncQueueView(),
    );
  }
}

class _SyncQueueView extends StatelessWidget {
  const _SyncQueueView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: BlocConsumer<SyncQueueCubit, SyncQueueState>(
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
          listener: (context, state) {
            SnackBarUtils.showError(context, state.errorMessage!);
          },
          builder: (context, state) {
            final cubit = context.read<SyncQueueCubit>();
            final visibleActions = state.visibleActions;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spaceMD,
                    AppDimensions.spaceMD,
                    AppDimensions.spaceMD,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr.syncQueueTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                SyncQueueTabs(
                  currentTab: state.tab,
                  pendingCount: state.pendingCount,
                  failedCount: state.failedCount,
                  onTabSelected: cubit.selectTab,
                ),
                Expanded(
                  child: visibleActions.isEmpty
                      ? SyncQueueEmptyState(tab: state.tab)
                      : RefreshIndicator(
                          onRefresh: cubit.retryAll,
                          color: AppColors.primary,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(
                              top: AppDimensions.spaceXS,
                              bottom: AppDimensions.spaceMD,
                            ),
                            itemCount: visibleActions.length,
                            itemBuilder: (context, index) {
                              final action = visibleActions[index];
                              return SyncActionCard(
                                action: action,
                                isRetrying:
                                    state.isActionRetrying(action.clientActionId),
                                onRetry: () =>
                                    cubit.retryAction(action.clientActionId),
                              );
                            },
                          ),
                        ),
                ),
                if (state.actions.isNotEmpty)
                  SyncQueueRetryAllButton(
                    isLoading: state.isRetryingAll,
                    onRetryAll: cubit.retryAll,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
