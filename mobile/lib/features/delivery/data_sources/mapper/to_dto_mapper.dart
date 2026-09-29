import '../../domain/entities/delivery_action.dart';
import '../models/request/complete_delivery_request_dto.dart';
import '../models/request/fail_delivery_request_dto.dart';


/// Extension mapping queued [DeliveryAction] objects to remote request DTOs.
extension DeliveryActionToDto on DeliveryAction {
  /// Converts a completion [DeliveryAction] into a [CompleteDeliveryRequestDto].
  CompleteDeliveryRequestDto toCompleteRequestDto() {
    return CompleteDeliveryRequestDto(
      recipientName: payload['recipient_name']?.toString() ?? '',
      note: payload['note']?.toString(),
      clientActionId: clientActionId,
      baseVersion: payload['base_version'] as int?,
    );
  }

  /// Converts a failure [DeliveryAction] into a [FailDeliveryRequestDto].
  FailDeliveryRequestDto toFailRequestDto() {
    return FailDeliveryRequestDto(
      reason: payload['reason']?.toString() ?? '',
      note: payload['note']?.toString(),
      clientActionId: clientActionId,
      baseVersion: payload['base_version'] as int?,
    );
  }
}
