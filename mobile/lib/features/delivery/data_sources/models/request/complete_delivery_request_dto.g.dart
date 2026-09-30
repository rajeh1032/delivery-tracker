// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_delivery_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteDeliveryRequestDto _$CompleteDeliveryRequestDtoFromJson(
  Map<String, dynamic> json,
) => CompleteDeliveryRequestDto(
  recipientName: json['recipient_name'] as String,
  note: json['note'] as String?,
  clientActionId: json['client_action_id'] as String,
  baseVersion: (json['base_version'] as num?)?.toInt(),
);

Map<String, dynamic> _$CompleteDeliveryRequestDtoToJson(
  CompleteDeliveryRequestDto instance,
) => <String, dynamic>{
  'recipient_name': instance.recipientName,
  'note': instance.note,
  'client_action_id': instance.clientActionId,
  'base_version': instance.baseVersion,
};
