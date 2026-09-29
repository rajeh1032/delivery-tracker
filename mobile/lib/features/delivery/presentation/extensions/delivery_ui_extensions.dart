import '../../domain/entities/delivery_entity.dart';

/// Presentation-layer computed getters on [DeliveryEntity] preserving domain purity.
extension DeliveryUiX on DeliveryEntity {
  /// Whether delivery action buttons (Mark as Delivered, Mark as Failed) can be tapped.
  bool get canAct => isPending && !isWaitingToSync && !isSyncing;

  /// Whether mutations are frozen due to pending or in-flight background sync.
  bool get isFrozen => isWaitingToSync || isSyncing;
}
