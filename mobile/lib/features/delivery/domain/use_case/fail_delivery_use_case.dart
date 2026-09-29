import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/delivery_entity.dart';
import '../entities/request/fail_delivery_request_entity.dart';
import '../repositories/delivery_repository.dart';

@injectable
class FailDeliveryUseCase {
  final DeliveryRepository _repository;

  FailDeliveryUseCase(this._repository);

  Future<ApiResult<DeliveryEntity>> invoke(FailDeliveryRequestEntity request) {
    return _repository.failDelivery(request);
  }
}
