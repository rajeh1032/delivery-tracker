import 'package:equatable/equatable.dart';
import 'package:delivery_tracker/core/utils/enums.dart';

/// Form and submission lifecycle status for delivery actions.
enum DeliveryActionStatus {
  initial,
  pickingPhoto,
  submitting,
  success,
  failure,
}

/// Unified state holding input fields, proof photo, UUID, and submission lifecycle.
class DeliveryActionState extends Equatable {
  final DeliveryActionStatus status;
  final DeliveryActionType? actionType;
  final String recipientName;
  final FailureReason? reason;
  final String note;
  final String? photoPath;
  final String clientActionId;
  final String? photoError;
  final String? errorMessage;

  const DeliveryActionState({
    this.status = DeliveryActionStatus.initial,
    this.actionType,
    this.recipientName = '',
    this.reason,
    this.note = '',
    this.photoPath,
    required this.clientActionId,
    this.photoError,
    this.errorMessage,
  });

  bool get isSubmitting => status == DeliveryActionStatus.submitting;
  bool get isSuccess => status == DeliveryActionStatus.success;
  bool get isFailure => status == DeliveryActionStatus.failure;
  bool get isPickingPhoto => status == DeliveryActionStatus.pickingPhoto;
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  DeliveryActionState copyWith({
    DeliveryActionStatus? status,
    DeliveryActionType? actionType,
    String? recipientName,
    FailureReason? reason,
    String? note,
    String? photoPath,
    bool clearPhoto = false,
    String? clientActionId,
    String? photoError,
    String? errorMessage,
  }) {
    return DeliveryActionState(
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      recipientName: recipientName ?? this.recipientName,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      clientActionId: clientActionId ?? this.clientActionId,
      photoError: photoError ?? this.photoError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        actionType,
        recipientName,
        reason,
        note,
        photoPath,
        clientActionId,
        photoError,
        errorMessage,
      ];
}
