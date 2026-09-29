import 'dart:io';
import '../../../../../core/network/api_results.dart';
import '../../models/request/complete_delivery_request_dto.dart';
import '../../models/request/fail_delivery_request_dto.dart';
import '../../models/response/delivery_response_dto.dart';

/// Contract for remote delivery network communication returning structured [ApiResult].
abstract interface class DeliveryRemoteDs {
  /// Fetches all deliveries assigned to the courier.
  Future<ApiResult<List<DeliveryResponseDto>>> getDeliveries();

  /// Fetches detailed delivery order by [id].
  Future<ApiResult<DeliveryResponseDto>> getDeliveryById(int id);

  /// Submits completion payload for delivery [id].
  Future<ApiResult<DeliveryActionResponseDto>> completeDelivery(
    int id,
    CompleteDeliveryRequestDto request,
  );

  /// Submits failure reason payload for delivery [id].
  Future<ApiResult<DeliveryActionResponseDto>> failDelivery(
    int id,
    FailDeliveryRequestDto request,
  );

  /// Uploads proof photo for delivery [id].
  Future<ApiResult<ProofUploadResponseDto>> uploadProof(
    int id,
    File photo,
  );
}
