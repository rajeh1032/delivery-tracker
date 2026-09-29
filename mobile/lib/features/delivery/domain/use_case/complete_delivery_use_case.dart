import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/delivery_entity.dart';
import '../entities/request/complete_delivery_request_entity.dart';
import '../repositories/delivery_repository.dart';

@injectable
class CompleteDeliveryUseCase {
  final DeliveryRepository _repository;

  CompleteDeliveryUseCase(this._repository);

  Future<ApiResult<DeliveryEntity>> invoke(
    CompleteDeliveryRequestEntity request,
  ) {
    return _repository.completeDelivery(request);
  }
}
