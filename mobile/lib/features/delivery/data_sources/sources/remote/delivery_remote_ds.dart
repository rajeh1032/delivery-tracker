import 'dart:io';
import '../../models/request/complete_delivery_request_dto.dart';
import '../../models/request/fail_delivery_request_dto.dart';
import '../../models/response/delivery_response_dto.dart';

/// Contract for remote delivery network communication.
abstract interface class DeliveryRemoteDs {
  /// Fetches all deliveries assigned to the courier.
  Future<List<DeliveryResponseDto>> getDeliveries();

  /// Fetches detailed delivery order by [id].
  Future<DeliveryResponseDto> getDeliveryById(int id);

  /// Submits completion payload for delivery [id].
  Future<DeliveryActionResponseDto> completeDelivery(
    int id,
    CompleteDeliveryRequestDto request,
  );

  /// Submits failure reason payload for delivery [id].
  Future<DeliveryActionResponseDto> failDelivery(
    int id,
    FailDeliveryRequestDto request,
  );

  /// Uploads proof photo for delivery [id].
  Future<ProofUploadResponseDto> uploadProof(
    int id,
    File photo,
  );
}
