import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/delivery_entity.dart';
import '../repositories/delivery_repository.dart';

@injectable
class GetDeliveriesUseCase {
  final DeliveryRepository _repository;

  GetDeliveriesUseCase(this._repository);

  Future<ApiResult<List<DeliveryEntity>>> invoke() {
    return _repository.getDeliveries();
  }
}
