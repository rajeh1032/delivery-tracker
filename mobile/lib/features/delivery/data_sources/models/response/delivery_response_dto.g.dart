// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryResponseDto _$DeliveryResponseDtoFromJson(Map<String, dynamic> json) =>
    DeliveryResponseDto(
      id: (json['id'] as num).toInt(),
      orderNumber: json['order_number'] as String,
      customerName: json['customer_name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      amountDue: DeliveryResponseDto._amountDueFromJson(json['amount_due']),
      paymentMethod: json['payment_method'] as String?,
      status: json['status'] as String,
      recipientName: json['recipient_name'] as String?,
      failureReason: json['failure_reason'] as String?,
      note: json['note'] as String?,
      proofUrl: json['proof_url'] as String?,
      version: (json['version'] as num?)?.toInt(),
      clientActionId: json['client_action_id'] as String?,
      completedAt: json['completed_at'] as String?,
      failedAt: json['failed_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$DeliveryResponseDtoToJson(
  DeliveryResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'order_number': instance.orderNumber,
  'customer_name': instance.customerName,
  'phone': instance.phone,
  'address': instance.address,
  'amount_due': instance.amountDue,
  'payment_method': instance.paymentMethod,
  'status': instance.status,
  'recipient_name': instance.recipientName,
  'failure_reason': instance.failureReason,
  'note': instance.note,
  'proof_url': instance.proofUrl,
  'version': instance.version,
  'client_action_id': instance.clientActionId,
  'completed_at': instance.completedAt,
  'failed_at': instance.failedAt,
  'updated_at': instance.updatedAt,
};

DeliveryActionResponseDto _$DeliveryActionResponseDtoFromJson(
  Map<String, dynamic> json,
) => DeliveryActionResponseDto(
  message: json['message'] as String,
  delivery: DeliveryResponseDto.fromJson(
    json['delivery'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$DeliveryActionResponseDtoToJson(
  DeliveryActionResponseDto instance,
) => <String, dynamic>{
  'message': instance.message,
  'delivery': instance.delivery,
};

ProofUploadResponseDto _$ProofUploadResponseDtoFromJson(
  Map<String, dynamic> json,
) => ProofUploadResponseDto(
  message: json['message'] as String,
  proofUrl: json['proof_url'] as String,
  delivery: json['delivery'] == null
      ? null
      : DeliveryResponseDto.fromJson(json['delivery'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProofUploadResponseDtoToJson(
  ProofUploadResponseDto instance,
) => <String, dynamic>{
  'message': instance.message,
  'proof_url': instance.proofUrl,
  'delivery': instance.delivery,
};
