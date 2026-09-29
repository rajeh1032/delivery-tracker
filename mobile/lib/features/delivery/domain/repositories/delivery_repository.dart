import '../../../../core/network/api_results.dart';
import '../entities/delivery_action.dart';
import '../entities/delivery_entity.dart';
import '../entities/request/complete_delivery_request_entity.dart';
import '../entities/request/fail_delivery_request_entity.dart';

abstract interface class DeliveryRepository {
  Future<ApiResult<List<DeliveryEntity>>> getDeliveries();

  Future<ApiResult<DeliveryEntity>> getDeliveryById(int id);

  Future<void> submitAction(DeliveryAction action);

  Future<ApiResult<DeliveryEntity>> completeDelivery(
    CompleteDeliveryRequestEntity request,
  );

  Future<ApiResult<DeliveryEntity>> failDelivery(
    FailDeliveryRequestEntity request,
  );

  Stream<List<DeliveryEntity>> watchDeliveries();
}
