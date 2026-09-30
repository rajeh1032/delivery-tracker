import 'dart:async';

import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/database/local_storage_service.dart';
import '../../../../../core/network/network_constants.dart';
import '../../../../../core/utils/enums.dart';
import '../../../domain/entities/delivery_action.dart';
import '../../../domain/entities/delivery_entity.dart';
import 'delivery_local_ds.dart';

/// Hive-backed implementation of [DeliveryLocalDataSource].
@Injectable(as: DeliveryLocalDataSource)
class DeliveryLocalDataSourceImpl implements DeliveryLocalDataSource {
  final LocalStorageService _storageService;
  Future<void> _writeTail = Future<void>.value();

  DeliveryLocalDataSourceImpl(this._storageService);

  Box<DeliveryEntity> get _deliveriesBox => _storageService.deliveriesBox;
  Box<DeliveryAction> get _actionsBox => _storageService.pendingActionsBox;

  @override
  Future<void> cacheDeliveries(List<DeliveryEntity> deliveries) async {
    await _withWriteLock(() async {
      final queuedByDelivery = <int, DeliveryAction>{};
      for (final action in _actionsBox.values) {
        final previous = queuedByDelivery[action.deliveryId];
        if (previous == null || previous.createdAt.isBefore(action.createdAt)) {
          queuedByDelivery[action.deliveryId] = action;
        }
      }
      final entries = <int, DeliveryEntity>{};
      for (final remote in deliveries) {
        final action = queuedByDelivery[remote.id];
        final cached = _deliveriesBox.get(remote.id);
        entries[remote.id] = action == null
            ? remote
            : _preserveQueuedDelivery(remote, cached, action);
      }
      for (final action in queuedByDelivery.values) {
        if (!entries.containsKey(action.deliveryId)) {
          final cached = _deliveriesBox.get(action.deliveryId);
          if (cached != null) {
            entries[action.deliveryId] = _preserveQueuedDelivery(
              cached,
              cached,
              action,
            );
          }
        }
      }
      await _deliveriesBox.putAll(entries);
    });
  }

  DeliveryEntity _preserveQueuedDelivery(
    DeliveryEntity refreshed,
    DeliveryEntity? cached,
    DeliveryAction action,
  ) {
    final current = cached ?? refreshed;
    final status = action.type == DeliveryActionType.complete
        ? DeliveryStatus.delivered
        : DeliveryStatus.failed;
    final syncStatus =
        action.status == SyncStatus.syncing ||
            current.syncStatus == SyncStatus.syncing
        ? SyncStatus.syncing
        : action.status == SyncStatus.failed ||
              current.syncStatus == SyncStatus.failed
        ? SyncStatus.failed
        : SyncStatus.waitingToSync;
    return refreshed.copyWith(
      status: status,
      syncStatus: syncStatus,
      recipientName:
          action.payload[NetworkConstants.keyRecipientName]?.toString() ??
          current.recipientName,
      failureReason:
          FailureReason.fromApiKeyOrNull(
            action.payload[NetworkConstants.keyReason]?.toString(),
          ) ??
          current.failureReason,
      note:
          action.payload[NetworkConstants.keyNote]?.toString() ?? current.note,
      proofUrl: current.proofUrl,
      clientActionId: action.clientActionId,
      version: current.version,
      updatedAt: current.updatedAt,
    );
  }

  @override
  Future<List<DeliveryEntity>> getDeliveries() async {
    return _deliveriesBox.values.toList();
  }

  @override
  Future<DeliveryEntity?> getDeliveryById(int id) async {
    return _deliveriesBox.get(id);
  }

  @override
  Future<void> updateDelivery(DeliveryEntity delivery) async {
    await _withWriteLock(() => _deliveriesBox.put(delivery.id, delivery));
  }

  @override
  Future<void> savePendingAction(DeliveryAction action) async {
    await _withWriteLock(() => _actionsBox.put(action.clientActionId, action));
  }

  @override
  Future<List<DeliveryAction>> getPendingActions() async {
    final actions = _actionsBox.values.toList();
    actions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return actions;
  }

  @override
  Future<void> deletePendingAction(String clientActionId) async {
    await _withWriteLock(() => _actionsBox.delete(clientActionId));
  }

  @override
  Future<int> reconcileStrandedSyncStates() async {
    final pendingActions = _actionsBox.values.toList();
    final pendingDeliveryIds = pendingActions.map((a) => a.deliveryId).toSet();
    final pendingClientActionIds = pendingActions
        .map((a) => a.clientActionId)
        .toSet();

    final cachedDeliveries = _deliveriesBox.values.toList();
    var reconciledCount = 0;
    for (final delivery in cachedDeliveries) {
      if (delivery.syncStatus != SyncStatus.synced) {
        final hasPendingAction =
            pendingDeliveryIds.contains(delivery.id) ||
            (delivery.clientActionId != null &&
                pendingClientActionIds.contains(delivery.clientActionId));

        if (!hasPendingAction) {
          final reconciled = delivery.copyWith(syncStatus: SyncStatus.synced);
          await _deliveriesBox.put(delivery.id, reconciled);
          reconciledCount++;
        }
      }
    }
    return reconciledCount;
  }

  @override
  Stream<List<DeliveryEntity>> watchDeliveries() async* {
    yield _deliveriesBox.values.toList();
    yield* _deliveriesBox.watch().map((_) => _deliveriesBox.values.toList());
  }

  @override
  Future<void> clearAll() async {
    await _withWriteLock(_storageService.clearAll);
  }

  Future<T> _withWriteLock<T>(Future<T> Function() operation) async {
    final previous = _writeTail;
    final release = Completer<void>();
    _writeTail = release.future;
    await previous;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }
}
