import '../../../domain/entities/delivery_action.dart';
import '../../../domain/entities/delivery_entity.dart';

/// Contract for offline-first local persistence of deliveries and pending mutation actions.
abstract interface class DeliveryLocalDataSource {
  /// Caches or updates a batch of delivery entities.
  Future<void> cacheDeliveries(List<DeliveryEntity> deliveries);

  /// Retrieves all cached delivery records.
  Future<List<DeliveryEntity>> getDeliveries();

  /// Retrieves a single delivery by its [id], or null if not cached.
  Future<DeliveryEntity?> getDeliveryById(int id);

  /// Updates or inserts a single delivery entity.
  Future<void> updateDelivery(DeliveryEntity delivery);

  /// Persists a pending mutation action into durable offline storage.
  Future<void> savePendingAction(DeliveryAction action);

  /// Retrieves all queued pending actions ordered by creation timestamp (FIFO).
  Future<List<DeliveryAction>> getPendingActions();

  /// Removes a pending action once successfully synchronized or dropped.
  Future<void> deletePendingAction(String clientActionId);

  /// Scans all cached deliveries on startup; if a delivery has `syncStatus != synced`
  /// but no corresponding action in `pending_actions_box`, resets its status to `synced`
  /// to prevent permanently stranded UI states.
  ///
  /// Returns the number of reconciled delivery records.
  Future<int> reconcileStrandedSyncStates();

  /// Provides a reactive stream of cached deliveries.
  Stream<List<DeliveryEntity>> watchDeliveries();

  /// Provides a reactive stream of queued pending actions.
  Stream<List<DeliveryAction>> watchPendingActions();

  /// Clears all cached deliveries and pending actions.
  Future<void> clearAll();
}
