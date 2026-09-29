import 'package:equatable/equatable.dart';
import 'package:delivery_tracker/core/utils/enums.dart';

/// Form and submission lifecycle status for marking a delivery as failed.
enum FailDeliveryStatus {
  editing,
  submitting,
  success,
  failure,
}

/// State holding selected failure reason, optional note, clientActionId, and status.
class FailDeliveryState extends Equatable {
  final FailDeliveryStatus status;
  final FailureReason? reason;
  final String note;
  final String clientActionId;
  final String? submissionError;

  const FailDeliveryState({
    this.status = FailDeliveryStatus.editing,
    this.reason,
    this.note = '',
    required this.clientActionId,
    this.submissionError,
  });

  bool get isSubmitting => status == FailDeliveryStatus.submitting;
  bool get isSuccess => status == FailDeliveryStatus.success;
  bool get isFailure => status == FailDeliveryStatus.failure;

  FailDeliveryState copyWith({
    FailDeliveryStatus? status,
    FailureReason? reason,
    String? note,
    String? clientActionId,
    String? submissionError,
  }) {
    return FailDeliveryState(
      status: status ?? this.status,
      reason: reason ?? this.reason,
      note: note ?? this.note,
      clientActionId: clientActionId ?? this.clientActionId,
      submissionError: submissionError ?? this.submissionError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reason,
        note,
        clientActionId,
        submissionError,
      ];
}
