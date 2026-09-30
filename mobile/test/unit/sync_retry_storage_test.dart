import 'dart:io';

import 'package:delivery_tracker/core/database/adapters/delivery_action_adapter.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _LegacyAdapter extends DeliveryActionAdapter {
  @override
  void write(BinaryWriter writer, DeliveryAction action) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(action.clientActionId)
      ..writeByte(1)
      ..write(action.deliveryId)
      ..writeByte(2)
      ..write(action.type.index)
      ..writeByte(3)
      ..write(action.payloadJson)
      ..writeByte(4)
      ..write(action.status.index)
      ..writeByte(5)
      ..write(action.createdAt.toIso8601String())
      ..writeByte(6)
      ..write(action.retryCount)
      ..writeByte(7)
      ..write(action.lastError);
  }
}

void main() {
  late Directory directory;
  final action = DeliveryAction(
    clientActionId: 'stable',
    deliveryId: 7,
    type: DeliveryActionType.complete,
    payload: const {'recipient_name': 'Sam'},
    createdAt: DateTime.utc(2026),
    status: SyncStatus.failed,
    retryCount: 2,
    nextRetryAt: DateTime.utc(2026, 10),
    autoRetryAllowed: false,
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('retry_storage_');
    Hive.init(directory.path);
    Hive.resetAdapters();
    Hive.registerAdapter(DeliveryActionAdapter());
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'retry eligibility, deadline, count and UUID survive closing storage',
    () async {
      var box = await Hive.openBox<DeliveryAction>('queue');
      await box.put(action.clientActionId, action);
      await box.close();
      box = await Hive.openBox<DeliveryAction>('queue');
      expect(box.get('stable'), action);
    },
  );

  test('old queue entries remain readable without retry metadata', () async {
    Hive.resetAdapters();
    Hive.registerAdapter(_LegacyAdapter());
    var box = await Hive.openBox<DeliveryAction>('legacy');
    await box.put('failed', action);
    await box.put(
      'waiting',
      action.copyWith(status: SyncStatus.waitingToSync, retryCount: 0),
    );
    await box.close();
    Hive.resetAdapters();
    Hive.registerAdapter(DeliveryActionAdapter());
    box = await Hive.openBox<DeliveryAction>('legacy');
    expect(box.get('failed')!.autoRetryAllowed, isTrue);
    expect(box.get('waiting')!.autoRetryAllowed, isTrue);
    expect(box.get('failed')!.nextRetryAt, isNull);
    expect(box.get('failed')!.retryCount, 2);
    expect(box.get('failed')!.clientActionId, 'stable');
  });
}
