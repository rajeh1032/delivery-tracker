import 'package:json_annotation/json_annotation.dart';

part 'fail_delivery_request_dto.g.dart';

/// Request body DTO for marking a delivery order as failed.
@JsonSerializable()
class FailDeliveryRequestDto {
  final String reason;
  final String? note;

  @JsonKey(name: 'client_action_id')
  final String clientActionId;

  @JsonKey(name: 'base_version')
  final int? baseVersion;

  const FailDeliveryRequestDto({
    required this.reason,
    this.note,
    required this.clientActionId,
    this.baseVersion,
  });

  factory FailDeliveryRequestDto.fromJson(Map<String, dynamic> json) =>
      _$FailDeliveryRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FailDeliveryRequestDtoToJson(this);
}
