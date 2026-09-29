import 'package:injectable/injectable.dart';

import '../entities/delivery_action.dart';
import '../repositories/delivery_repository.dart';

@injectable
class RetryActionUseCase {
  final DeliveryRepository _repository;

  RetryActionUseCase(this._repository);

  Future<void> invoke(DeliveryAction action) {
    return _repository.submitAction(action);
  }
}
