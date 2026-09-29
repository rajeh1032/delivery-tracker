import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/repositories/delivery_repository.dart';
import 'sync_queue_state.dart';

/// Cubit managing queued offline sync actions, reactive stream updates, and retry executions.
@injectable
class SyncQueueCubit extends Cubit<SyncQueueState> {
  final DeliveryRepository _deliveryRepository;
  final SyncManager _syncManager;
  StreamSubscription<List<DeliveryAction>>? _actionsSubscription;

  SyncQueueCubit(
    this._deliveryRepository,
    this._syncManager,
  ) : super(const SyncQueueState()) {
    _actionsSubscription = _deliveryRepository.watchPendingActions().listen(
      (actions) {
        emit(state.copyWith(actions: actions));
      },
    );
  }

  /// Switches active tab between pending and failed queues.
  void selectTab(SyncQueueTab tab) {
    emit(state.copyWith(tab: tab));
  }

  /// Retries a single pending or failed action by its [clientActionId].
  Future<void> retryAction(String clientActionId) async {
    final updated = Set<String>.from(state.retryingIds)..add(clientActionId);
    emit(state.copyWith(retryingIds: updated));

    try {
      await _syncManager.retryAction(clientActionId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      final cleared = Set<String>.from(state.retryingIds)
        ..remove(clientActionId);
      emit(state.copyWith(retryingIds: cleared));
    }
  }

  /// Retries all queued actions sequentially.
  Future<void> retryAll() async {
    if (state.isRetryingAll) return;
    emit(state.copyWith(isRetryingAll: true));

    try {
      await _syncManager.processQueue();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isRetryingAll: false));
    }
  }

  @override
  Future<void> close() {
    _actionsSubscription?.cancel();
    return super.close();
  }
}
