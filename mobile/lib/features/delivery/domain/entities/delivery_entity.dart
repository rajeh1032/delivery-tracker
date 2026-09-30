import 'package:equatable/equatable.dart';
import '../../../../core/helpers/customer_location_helper.dart';
import '../../../../core/utils/enums.dart';

/// Domain entity representing a delivery order with offline synchronization metadata.
class DeliveryEntity extends Equatable {
  final int id;
  final String orderNumber;
  final String customerName;
  final String phone;
  final String address;
  final double amountDue;
  final String paymentMethod;
  final DeliveryStatus status;
  final SyncStatus syncStatus;
  final String? recipientName;
  final FailureReason? failureReason;
  final String? note;
  final String? proofUrl;
  final String? clientActionId;
  final int version;
  final DateTime? updatedAt;
  final double? latitude;
  final double? longitude;

  const DeliveryEntity({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.amountDue,
    this.paymentMethod = 'cash',
    this.status = DeliveryStatus.pending,
    this.syncStatus = SyncStatus.synced,
    this.recipientName,
    this.failureReason,
    this.note,
    this.proofUrl,
    this.clientActionId,
    this.version = 1,
    this.updatedAt,
    this.latitude,
    this.longitude,
  });

  /// Resolved latitude for customer location (with address fallback).
  double get customerLatitude => CustomerLocationHelper.getCoordinates(
        address: address,
        latitude: latitude,
        longitude: longitude,
      ).latitude;

  /// Resolved longitude for customer location (with address fallback).
  double get customerLongitude => CustomerLocationHelper.getCoordinates(
        address: address,
        latitude: latitude,
        longitude: longitude,
      ).longitude;

  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isFailed => status == DeliveryStatus.failed;
  bool get isPending => status == DeliveryStatus.pending;
  bool get isSynced => syncStatus == SyncStatus.synced;
  bool get isWaitingToSync => syncStatus == SyncStatus.waitingToSync;
  bool get isSyncing => syncStatus == SyncStatus.syncing;
  bool get isSyncFailed => syncStatus == SyncStatus.failed;

  DeliveryEntity copyWith({
    int? id,
    String? orderNumber,
    String? customerName,
    String? phone,
    String? address,
    double? amountDue,
    String? paymentMethod,
    DeliveryStatus? status,
    SyncStatus? syncStatus,
    String? recipientName,
    FailureReason? failureReason,
    String? note,
    String? proofUrl,
    String? clientActionId,
    int? version,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      amountDue: amountDue ?? this.amountDue,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      recipientName: recipientName ?? this.recipientName,
      failureReason: failureReason ?? this.failureReason,
      note: note ?? this.note,
      proofUrl: proofUrl ?? this.proofUrl,
      clientActionId: clientActionId ?? this.clientActionId,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerName,
        phone,
        address,
        amountDue,
        paymentMethod,
        status,
        syncStatus,
        recipientName,
        failureReason,
        note,
        proofUrl,
        clientActionId,
        version,
        updatedAt,
        latitude,
        longitude,
      ];
}
