// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fail_delivery_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FailDeliveryRequestDto _$FailDeliveryRequestDtoFromJson(
  Map<String, dynamic> json,
) => FailDeliveryRequestDto(
  reason: json['reason'] as String,
  note: json['note'] as String?,
  clientActionId: json['client_action_id'] as String,
  baseVersion: (json['base_version'] as num?)?.toInt(),
);

Map<String, dynamic> _$FailDeliveryRequestDtoToJson(
  FailDeliveryRequestDto instance,
) => <String, dynamic>{
  'reason': instance.reason,
  'note': instance.note,
  'client_action_id': instance.clientActionId,
  'base_version': instance.baseVersion,
};
