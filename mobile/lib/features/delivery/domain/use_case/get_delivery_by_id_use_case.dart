import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/delivery_entity.dart';
import '../repositories/delivery_repository.dart';

@injectable
class GetDeliveryByIdUseCase {
  final DeliveryRepository _repository;

  GetDeliveryByIdUseCase(this._repository);

  Future<ApiResult<DeliveryEntity>> invoke(int id) {
    return _repository.getDeliveryById(id);
  }
}
