import 'package:equatable/equatable.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';

/// Available tabs in the offline sync queue.
enum SyncQueueTab { pending, failed }

/// State containing queued mutation actions, selected tab, and retry flags.
class SyncQueueState extends Equatable {
  final List<DeliveryAction> actions;
  final SyncQueueTab tab;
  final bool isRetryingAll;
  final Set<String> retryingIds;
  final String? errorMessage;

  const SyncQueueState({
    this.actions = const [],
    this.tab = SyncQueueTab.pending,
    this.isRetryingAll = false,
    this.retryingIds = const {},
    this.errorMessage,
  });

  /// Actions visible under the active tab.
  List<DeliveryAction> get visibleActions => tab == SyncQueueTab.pending
      ? actions.where((a) => a.status != SyncStatus.failed).toList()
      : actions.where((a) => a.status == SyncStatus.failed).toList();

  /// Total count of pending actions.
  int get pendingCount =>
      actions.where((a) => a.status != SyncStatus.failed).length;

  /// Total count of failed actions.
  int get failedCount =>
      actions.where((a) => a.status == SyncStatus.failed).length;

  /// Whether a specific action is currently retrying.
  bool isActionRetrying(String clientActionId) =>
      retryingIds.contains(clientActionId) || isRetryingAll;

  SyncQueueState copyWith({
    List<DeliveryAction>? actions,
    SyncQueueTab? tab,
    bool? isRetryingAll,
    Set<String>? retryingIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncQueueState(
      actions: actions ?? this.actions,
      tab: tab ?? this.tab,
      isRetryingAll: isRetryingAll ?? this.isRetryingAll,
      retryingIds: retryingIds ?? this.retryingIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        actions,
        tab,
        isRetryingAll,
        retryingIds,
        errorMessage,
      ];
}
