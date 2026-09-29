import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/database/local_storage_service.dart';
import '../../../../../core/utils/enums.dart';
import '../../../domain/entities/delivery_action.dart';
import '../../../domain/entities/delivery_entity.dart';
import 'delivery_local_ds.dart';

/// Hive-backed implementation of [DeliveryLocalDataSource].
@Injectable(as: DeliveryLocalDataSource)
class DeliveryLocalDataSourceImpl implements DeliveryLocalDataSource {
  final LocalStorageService _storageService;

  DeliveryLocalDataSourceImpl(this._storageService);

  Box<DeliveryEntity> get _deliveriesBox => _storageService.deliveriesBox;
  Box<DeliveryAction> get _actionsBox => _storageService.pendingActionsBox;

  @override
  Future<void> cacheDeliveries(List<DeliveryEntity> deliveries) async {
    final entries = <int, DeliveryEntity>{
      for (final delivery in deliveries) delivery.id: delivery,
    };
    await _deliveriesBox.putAll(entries);
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
    await _deliveriesBox.put(delivery.id, delivery);
  }

  @override
  Future<void> savePendingAction(DeliveryAction action) async {
    await _actionsBox.put(action.clientActionId, action);
  }

  @override
  Future<List<DeliveryAction>> getPendingActions() async {
    final actions = _actionsBox.values.toList();
    actions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return actions;
  }

  @override
  Future<void> deletePendingAction(String clientActionId) async {
    await _actionsBox.delete(clientActionId);
  }

  @override
  Future<int> reconcileStrandedSyncStates() async {
    final pendingActions = _actionsBox.values.toList();
    final pendingDeliveryIds = pendingActions.map((a) => a.deliveryId).toSet();
    final pendingClientActionIds =
        pendingActions.map((a) => a.clientActionId).toSet();

    var reconciledCount = 0;
    for (final delivery in _deliveriesBox.values) {
      if (delivery.syncStatus != SyncStatus.synced) {
        final hasPendingAction = pendingDeliveryIds.contains(delivery.id) ||
            (delivery.clientActionId != null &&
                pendingClientActionIds.contains(delivery.clientActionId));

        if (!hasPendingAction) {
          final reconciled = delivery.copyWith(
            syncStatus: SyncStatus.synced,
          );
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
    await _storageService.clearAll();
  }
}
