import 'package:equatable/equatable.dart';

/// Form and submission lifecycle status for delivery completion.
enum CompleteDeliveryStatus {
  editing,
  pickingPhoto,
  submitting,
  success,
  failure,
}

/// State holding input fields, durable photo path, immutable UUID, and status.
class CompleteDeliveryState extends Equatable {
  final CompleteDeliveryStatus status;
  final String recipientName;
  final String note;
  final String? photoPath;
  final String clientActionId;
  final String? photoError;
  final String? submissionError;

  const CompleteDeliveryState({
    this.status = CompleteDeliveryStatus.editing,
    this.recipientName = '',
    this.note = '',
    this.photoPath,
    required this.clientActionId,
    this.photoError,
    this.submissionError,
  });

  bool get isSubmitting => status == CompleteDeliveryStatus.submitting;
  bool get isSuccess => status == CompleteDeliveryStatus.success;
  bool get isFailure => status == CompleteDeliveryStatus.failure;
  bool get isPickingPhoto => status == CompleteDeliveryStatus.pickingPhoto;
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  CompleteDeliveryState copyWith({
    CompleteDeliveryStatus? status,
    String? recipientName,
    String? note,
    String? photoPath,
    bool clearPhoto = false,
    String? clientActionId,
    String? photoError,
    String? submissionError,
  }) {
    return CompleteDeliveryState(
      status: status ?? this.status,
      recipientName: recipientName ?? this.recipientName,
      note: note ?? this.note,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      clientActionId: clientActionId ?? this.clientActionId,
      photoError: photoError ?? this.photoError,
      submissionError: submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recipientName,
        note,
        photoPath,
        clientActionId,
        photoError,
        submissionError,
      ];
}
