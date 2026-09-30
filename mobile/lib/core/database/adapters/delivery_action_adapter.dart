import 'dart:convert';
import 'package:hive/hive.dart';

import '../../../core/utils/enums.dart';
import '../../../features/delivery/domain/entities/delivery_action.dart';

/// Handwritten Hive [TypeAdapter] for [DeliveryAction] (TypeId: 1).
///
/// Implemented manually to prevent build_runner analyzer deadlocks
/// caused by code generator packages.
class DeliveryActionAdapter extends TypeAdapter<DeliveryAction> {
  @override
  final int typeId = 1;

  @override
  DeliveryAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final rawPayload = fields[3];
    Map<String, dynamic> payload;
    if (rawPayload is String) {
      try {
        payload = Map<String, dynamic>.from(jsonDecode(rawPayload) as Map);
      } catch (_) {
        payload = const <String, dynamic>{};
      }
    } else if (rawPayload is Map) {
      payload = Map<String, dynamic>.from(rawPayload);
    } else {
      payload = const <String, dynamic>{};
    }

    return DeliveryAction(
      clientActionId: fields[0] as String,
      deliveryId: fields[1] as int,
      type: _parseDeliveryActionType(fields[2]),
      payload: payload,
      status: _parseSyncStatus(fields[4]),
      createdAt: _parseDateTime(fields[5]) ?? DateTime.now(),
      retryCount: fields[6] as int? ?? 0,
      lastError: fields[7] as String?,
      autoRetryAllowed: fields[8] as bool? ?? true,
      nextRetryAt: _parseDateTime(fields[9]),
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryAction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.clientActionId)
      ..writeByte(1)
      ..write(obj.deliveryId)
      ..writeByte(2)
      ..write(obj.type.index)
      ..writeByte(3)
      ..write(jsonEncode(obj.payload))
      ..writeByte(4)
      ..write(obj.status.index)
      ..writeByte(5)
      ..write(obj.createdAt.toIso8601String())
      ..writeByte(6)
      ..write(obj.retryCount)
      ..writeByte(7)
      ..write(obj.lastError)
      ..writeByte(8)
      ..write(obj.autoRetryAllowed)
      ..writeByte(9)
      ..write(obj.nextRetryAt?.toIso8601String());
  }

  static DeliveryActionType _parseDeliveryActionType(dynamic value) {
    if (value is int &&
        value >= 0 &&
        value < DeliveryActionType.values.length) {
      return DeliveryActionType.values[value];
    }
    if (value is String) {
      return DeliveryActionType.fromApiKeyOrNull(value) ??
          DeliveryActionType.complete;
    }
    return DeliveryActionType.complete;
  }

  static SyncStatus _parseSyncStatus(dynamic value) {
    if (value is int && value >= 0 && value < SyncStatus.values.length) {
      return SyncStatus.values[value];
    }
    if (value is String) {
      return SyncStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SyncStatus.waitingToSync,
      );
    }
    return SyncStatus.waitingToSync;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
