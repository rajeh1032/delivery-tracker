import '../../../../core/utils/constants.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/delivery_entity.dart';
import '../models/response/delivery_response_dto.dart';


/// Extension mapping delivery response DTOs to immutable domain entities.
extension DeliveryResponseDtoToEntity on DeliveryResponseDto {
  /// Converts [DeliveryResponseDto] to domain [DeliveryEntity].
  DeliveryEntity toEntity() {
    DateTime? parsedDate;
    if (updatedAt != null && updatedAt!.isNotEmpty) {
      parsedDate = DateTime.tryParse(updatedAt!);
    } else if (completedAt != null && completedAt!.isNotEmpty) {
      parsedDate = DateTime.tryParse(completedAt!);
    } else if (failedAt != null && failedAt!.isNotEmpty) {
      parsedDate = DateTime.tryParse(failedAt!);
    }


    return DeliveryEntity(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName,
      phone: phone,
      address: address,
      amountDue: amountDue,
      paymentMethod: paymentMethod ?? AppConstants.defaultPaymentMethod,
      status: DeliveryStatus.fromApiKey(status),
      syncStatus: SyncStatus.synced,
      recipientName: recipientName,
      failureReason: FailureReason.fromApiKeyOrNull(failureReason),
      note: note,
      proofUrl: proofUrl,
      clientActionId: clientActionId,
      version: version ?? 1,
      updatedAt: parsedDate,
    );
  }
}

/// Extension mapping collections of [DeliveryResponseDto] to domain entities.
extension DeliveryResponseDtoListToEntity on List<DeliveryResponseDto> {
  /// Converts a list of DTOs into a list of [DeliveryEntity].
  List<DeliveryEntity> toEntities() =>
      map((dto) => dto.toEntity()).toList(growable: false);
}
