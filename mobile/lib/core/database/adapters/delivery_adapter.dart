import 'package:hive/hive.dart';

import '../../../core/utils/enums.dart';
import '../../../features/delivery/domain/entities/delivery_entity.dart';

/// Handwritten Hive [TypeAdapter] for [DeliveryEntity] (TypeId: 0).
///
/// Implemented manually to prevent build_runner analyzer deadlocks
/// caused by code generator packages.
class DeliveryAdapter extends TypeAdapter<DeliveryEntity> {
  @override
  final int typeId = 0;

  @override
  DeliveryEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return DeliveryEntity(
      id: fields[0] as int,
      orderNumber: fields[1] as String,
      customerName: fields[2] as String,
      phone: fields[3] as String,
      address: fields[4] as String,
      amountDue: (fields[5] as num).toDouble(),
      paymentMethod: fields[6] as String? ?? 'cash',
      status: _parseDeliveryStatus(fields[7]),
      syncStatus: _parseSyncStatus(fields[8]),
      recipientName: fields[9] as String?,
      failureReason: _parseFailureReason(fields[10]),
      note: fields[11] as String?,
      proofUrl: fields[12] as String?,
      clientActionId: fields[13] as String?,
      version: fields[14] as int? ?? 1,
      updatedAt: _parseDateTime(fields[15]),
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryEntity obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderNumber)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.amountDue)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.status.index)
      ..writeByte(8)
      ..write(obj.syncStatus.index)
      ..writeByte(9)
      ..write(obj.recipientName)
      ..writeByte(10)
      ..write(obj.failureReason?.index)
      ..writeByte(11)
      ..write(obj.note)
      ..writeByte(12)
      ..write(obj.proofUrl)
      ..writeByte(13)
      ..write(obj.clientActionId)
      ..writeByte(14)
      ..write(obj.version)
      ..writeByte(15)
      ..write(obj.updatedAt?.toIso8601String());
  }

  static DeliveryStatus _parseDeliveryStatus(dynamic value) {
    if (value is int && value >= 0 && value < DeliveryStatus.values.length) {
      return DeliveryStatus.values[value];
    }
    if (value is String) {
      return DeliveryStatus.fromApiKeyOrNull(value) ?? DeliveryStatus.pending;
    }
    return DeliveryStatus.pending;
  }

  static SyncStatus _parseSyncStatus(dynamic value) {
    if (value is int && value >= 0 && value < SyncStatus.values.length) {
      return SyncStatus.values[value];
    }
    if (value is String) {
      return SyncStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SyncStatus.synced,
      );
    }
    return SyncStatus.synced;
  }

  static FailureReason? _parseFailureReason(dynamic value) {
    if (value == null) return null;
    if (value is int && value >= 0 && value < FailureReason.values.length) {
      return FailureReason.values[value];
    }
    if (value is String) {
      return FailureReason.fromApiKeyOrNull(value);
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
