import 'package:json_annotation/json_annotation.dart';

part 'delivery_response_dto.g.dart';

/// DTO representing delivery record received from remote backend API.
@JsonSerializable()
class DeliveryResponseDto {
  final int id;

  @JsonKey(name: 'order_number')
  final String orderNumber;

  @JsonKey(name: 'customer_name')
  final String customerName;

  final String phone;
  final String address;

  @JsonKey(name: 'amount_due', fromJson: _amountDueFromJson)
  final double amountDue;

  @JsonKey(name: 'payment_method')
  final String? paymentMethod;

  final String status;

  @JsonKey(name: 'recipient_name')
  final String? recipientName;

  @JsonKey(name: 'failure_reason')
  final String? failureReason;

  final String? note;

  @JsonKey(name: 'proof_url')
  final String? proofUrl;

  final int? version;

  @JsonKey(name: 'client_action_id')
  final String? clientActionId;

  @JsonKey(name: 'completed_at')
  final String? completedAt;

  @JsonKey(name: 'failed_at')
  final String? failedAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const DeliveryResponseDto({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.amountDue,
    this.paymentMethod,
    required this.status,
    this.recipientName,
    this.failureReason,
    this.note,
    this.proofUrl,
    this.version,
    this.clientActionId,
    this.completedAt,
    this.failedAt,
    this.updatedAt,
  });


  static double _amountDueFromJson(dynamic val) =>
      (val as num?)?.toDouble() ?? 0.0;

  factory DeliveryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DeliveryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryResponseDtoToJson(this);
}

/// DTO representing the response payload for delivery mutations (complete/fail).
@JsonSerializable()
class DeliveryActionResponseDto {
  final String message;
  final DeliveryResponseDto delivery;

  const DeliveryActionResponseDto({
    required this.message,
    required this.delivery,
  });

  factory DeliveryActionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DeliveryActionResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryActionResponseDtoToJson(this);
}

/// DTO representing proof photo upload response payload.
@JsonSerializable()
class ProofUploadResponseDto {
  final String message;

  @JsonKey(name: 'proof_url')
  final String proofUrl;

  final DeliveryResponseDto? delivery;

  const ProofUploadResponseDto({
    required this.message,
    required this.proofUrl,
    this.delivery,
  });

  factory ProofUploadResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProofUploadResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProofUploadResponseDtoToJson(this);
}
