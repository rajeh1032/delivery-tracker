import 'package:equatable/equatable.dart';

class CompleteDeliveryRequestEntity extends Equatable {
  final int deliveryId;
  final String recipientName;
  final String? note;
  final String clientActionId;
  final int? baseVersion;

  const CompleteDeliveryRequestEntity({
    required this.deliveryId,
    required this.recipientName,
    this.note,
    required this.clientActionId,
    this.baseVersion,
  });

  @override
  List<Object?> get props => [
        deliveryId,
        recipientName,
        note,
        clientActionId,
        baseVersion,
      ];
}
