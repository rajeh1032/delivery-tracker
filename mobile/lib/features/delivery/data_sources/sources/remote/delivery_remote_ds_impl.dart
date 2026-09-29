import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_services.dart';
import '../../models/request/complete_delivery_request_dto.dart';
import '../../models/request/fail_delivery_request_dto.dart';
import '../../models/response/delivery_response_dto.dart';
import 'delivery_remote_ds.dart';

/// Implementation of [DeliveryRemoteDs] delegating network calls to [ApiServices].
@Injectable(as: DeliveryRemoteDs)
class DeliveryRemoteDsImpl implements DeliveryRemoteDs {
  final ApiServices _apiServices;

  DeliveryRemoteDsImpl(this._apiServices);

  @override
  Future<List<DeliveryResponseDto>> getDeliveries() {
    return _apiServices.getDeliveries();
  }

  @override
  Future<DeliveryResponseDto> getDeliveryById(int id) {
    return _apiServices.getDeliveryById(id);
  }

  @override
  Future<DeliveryActionResponseDto> completeDelivery(
    int id,
    CompleteDeliveryRequestDto request,
  ) {
    return _apiServices.completeDelivery(id, request);
  }

  @override
  Future<DeliveryActionResponseDto> failDelivery(
    int id,
    FailDeliveryRequestDto request,
  ) {
    return _apiServices.failDelivery(id, request);
  }

  @override
  Future<ProofUploadResponseDto> uploadProof(
    int id,
    File photo,
  ) {
    return _apiServices.uploadProof(id, photo);
  }
}
