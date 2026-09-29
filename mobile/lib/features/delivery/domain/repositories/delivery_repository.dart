import '../../../../core/network/api_results.dart';
import '../entities/delivery_action.dart';
import '../entities/delivery_entity.dart';

/// Contract for the delivery repository managing offline-first caching and sync operations.
abstract interface class DeliveryRepository {
  /// Fetches all deliveries (cache-first or remote sync depending on policy).
  Future<ApiResult<List<DeliveryEntity>>> getDeliveries();

  /// Fetches a specific delivery order by [id].
  Future<ApiResult<DeliveryEntity>> getDeliveryById(int id);

  /// Submits a delivery mutation action (complete or fail) to local queue and triggers sync.
  Future<void> submitAction(DeliveryAction action);

  /// Provides a reactive stream of local delivery records, updating on any cache modification.
  Stream<List<DeliveryEntity>> watchDeliveries();
}
