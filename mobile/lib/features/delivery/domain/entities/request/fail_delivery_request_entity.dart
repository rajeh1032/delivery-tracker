import 'package:equatable/equatable.dart';

import '../../../../../core/utils/enums.dart';

class FailDeliveryRequestEntity extends Equatable {
  final int deliveryId;
  final FailureReason reason;
  final String? note;
  final String clientActionId;
  final int? baseVersion;

  const FailDeliveryRequestEntity({
    required this.deliveryId,
    required this.reason,
    this.note,
    required this.clientActionId,
    this.baseVersion,
  });

  @override
  List<Object?> get props => [
        deliveryId,
        reason,
        note,
        clientActionId,
        baseVersion,
      ];
}
