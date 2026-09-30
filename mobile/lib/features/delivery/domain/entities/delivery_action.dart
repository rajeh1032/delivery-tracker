import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

/// Domain entity representing an idempotent mutation action queued for synchronization.
class DeliveryAction extends Equatable {
  final String clientActionId;
  final int deliveryId;
  final DeliveryActionType type;
  final Map<String, dynamic> payload;
  final SyncStatus status;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  const DeliveryAction({
    required this.clientActionId,
    required this.deliveryId,
    required this.type,
    required this.payload,
    this.status = SyncStatus.waitingToSync,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  String get payloadJson => jsonEncode(payload);

  bool get isWaitingToSync => status == SyncStatus.waitingToSync;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get isSynced => status == SyncStatus.synced;
  bool get isFailed => status == SyncStatus.failed;

  DeliveryAction copyWith({
    String? clientActionId,
    int? deliveryId,
    DeliveryActionType? type,
    Map<String, dynamic>? payload,
    SyncStatus? status,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
  }) {
    return DeliveryAction(
      clientActionId: clientActionId ?? this.clientActionId,
      deliveryId: deliveryId ?? this.deliveryId,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  List<Object?> get props => [
        clientActionId,
        deliveryId,
        type,
        payload,
        status,
        createdAt,
        retryCount,
        lastError,
      ];
}
