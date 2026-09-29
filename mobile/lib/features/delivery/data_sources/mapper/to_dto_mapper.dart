import '../../../../core/network/network_constants.dart';
import '../../domain/entities/delivery_action.dart';
import '../models/request/complete_delivery_request_dto.dart';
import '../models/request/fail_delivery_request_dto.dart';

/// Extension mapping queued [DeliveryAction] objects to remote request DTOs.
extension DeliveryActionToDto on DeliveryAction {
  /// Converts a completion [DeliveryAction] into a [CompleteDeliveryRequestDto].
  CompleteDeliveryRequestDto toCompleteRequestDto() {
    return CompleteDeliveryRequestDto(
      recipientName:
          payload[NetworkConstants.keyRecipientName]?.toString() ?? '',
      note: payload[NetworkConstants.keyNote]?.toString(),
      clientActionId: clientActionId,
      baseVersion: payload[NetworkConstants.keyBaseVersion] as int?,
    );
  }

  /// Converts a failure [DeliveryAction] into a [FailDeliveryRequestDto].
  FailDeliveryRequestDto toFailRequestDto() {
    return FailDeliveryRequestDto(
      reason: payload[NetworkConstants.keyReason]?.toString() ?? '',
      note: payload[NetworkConstants.keyNote]?.toString(),
      clientActionId: clientActionId,
      baseVersion: payload[NetworkConstants.keyBaseVersion] as int?,
    );
  }
}
