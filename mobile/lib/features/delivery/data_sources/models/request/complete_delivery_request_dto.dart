import 'package:json_annotation/json_annotation.dart';

part 'complete_delivery_request_dto.g.dart';

/// Request body DTO for completing a delivery order.
@JsonSerializable()
class CompleteDeliveryRequestDto {
  @JsonKey(name: 'recipient_name')
  final String recipientName;

  final String? note;

  @JsonKey(name: 'client_action_id')
  final String clientActionId;

  @JsonKey(name: 'base_version')
  final int? baseVersion;

  const CompleteDeliveryRequestDto({
    required this.recipientName,
    this.note,
    required this.clientActionId,
    this.baseVersion,
  });

  factory CompleteDeliveryRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CompleteDeliveryRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteDeliveryRequestDtoToJson(this);
}
