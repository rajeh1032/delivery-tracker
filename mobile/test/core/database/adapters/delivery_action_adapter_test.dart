import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:delivery_tracker/core/database/adapters/delivery_action_adapter.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';

void main() {
  late Directory tempDir;
  late DeliveryActionAdapter adapter;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('delivery_action_adapter_test_');
    Hive.init(tempDir.path);
    adapter = DeliveryActionAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('DeliveryActionAdapter', () {
    test('has correct typeId 1', () {
      expect(adapter.typeId, equals(1));
    });

    test('serializes and deserializes DeliveryAction with complex payload Map', () async {
      final box = await Hive.openBox<DeliveryAction>('test_action_box');
      final original = DeliveryAction(
        clientActionId: 'action-uuid-complete-1',
        deliveryId: 201,
        type: DeliveryActionType.complete,
        payload: {
          'recipient_name': 'Khaled Al-Otaibi',
          'note': 'Customer received and signed',
          'nested_meta': {'channel': 'knet', 'cash_received': 0},
        },
        status: SyncStatus.waitingToSync,
        createdAt: DateTime.utc(2026, 9, 29, 14, 0),
        retryCount: 2,
        lastError: 'Connection timeout on socket 3000',
      );

      await box.put(original.clientActionId, original);
      final restored = box.get(original.clientActionId);

      expect(restored, isNotNull);
      expect(restored!.clientActionId, equals(original.clientActionId));
      expect(restored.deliveryId, equals(201));
      expect(restored.type, equals(DeliveryActionType.complete));
      expect(restored.payload['recipient_name'], equals('Khaled Al-Otaibi'));
      expect(restored.payload['note'], equals('Customer received and signed'));
      expect(restored.payload['nested_meta'], isA<Map>());
      expect(restored.status, equals(SyncStatus.waitingToSync));
      expect(restored.createdAt, equals(DateTime.utc(2026, 9, 29, 14, 0)));
      expect(restored.retryCount, equals(2));
      expect(restored.lastError, equals('Connection timeout on socket 3000'));
    });

    test('handles fail action with reason in payload and null lastError', () async {
      final box = await Hive.openBox<DeliveryAction>('test_action_fail_box');
      final failAction = DeliveryAction(
        clientActionId: 'action-uuid-fail-1',
        deliveryId: 202,
        type: DeliveryActionType.fail,
        payload: {
          'reason': 'customer_unavailable',
          'note': 'No answer at intercom',
        },
        status: SyncStatus.syncing,
        createdAt: DateTime.utc(2026, 9, 29, 15, 30),
      );

      await box.put(failAction.clientActionId, failAction);
      final restored = box.get(failAction.clientActionId);

      expect(restored, isNotNull);
      expect(restored!.type, equals(DeliveryActionType.fail));
      expect(restored.status, equals(SyncStatus.syncing));
      expect(restored.retryCount, equals(0));
      expect(restored.lastError, isNull);
    });
  });
}
