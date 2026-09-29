import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../../../../core/network/api_results.dart';
import '../../../../../core/network/api_services.dart';
import '../../models/request/complete_delivery_request_dto.dart';
import '../../models/request/fail_delivery_request_dto.dart';
import '../../models/response/delivery_response_dto.dart';
import 'delivery_remote_ds.dart';

/// Implementation of [DeliveryRemoteDs] delegating network calls to [ApiServices]
/// and wrapping them into safe [ApiResult] containers.
@Injectable(as: DeliveryRemoteDs)
class DeliveryRemoteDsImpl implements DeliveryRemoteDs {
  final ApiServices _apiServices;

  DeliveryRemoteDsImpl(this._apiServices);

  @override
  Future<ApiResult<List<DeliveryResponseDto>>> getDeliveries() {
    return safeApiCall(() => _apiServices.getDeliveries());
  }

  @override
  Future<ApiResult<DeliveryResponseDto>> getDeliveryById(int id) {
    return safeApiCall(() => _apiServices.getDeliveryById(id));
  }

  @override
  Future<ApiResult<DeliveryActionResponseDto>> completeDelivery(
    int id,
    CompleteDeliveryRequestDto request,
  ) {
    return safeApiCall(() => _apiServices.completeDelivery(id, request));
  }

  @override
  Future<ApiResult<DeliveryActionResponseDto>> failDelivery(
    int id,
    FailDeliveryRequestDto request,
  ) {
    return safeApiCall(() => _apiServices.failDelivery(id, request));
  }

  @override
  Future<ApiResult<ProofUploadResponseDto>> uploadProof(
    int id,
    File photo,
  ) {
    return safeApiCall(() => _apiServices.uploadProof(id, photo));
  }
}
