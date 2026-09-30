import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:delivery_tracker/core/database/local_storage_service.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('local_storage_test_');
    service = LocalStorageService();
  });

  tearDown(() async {
    if (service.isInitialized) {
      await service.close();
    }
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LocalStorageService', () {
    test('throws StateError when accessing boxes before init()', () {
      expect(() => service.deliveriesBox, throwsStateError);
      expect(() => service.pendingActionsBox, throwsStateError);
      expect(service.isInitialized, isFalse);
    });

    test('initializes Hive, registers adapters, and provides open boxes', () async {
      await service.init(path: tempDir.path);

      expect(service.isInitialized, isTrue);
      expect(service.deliveriesBox.isOpen, isTrue);
      expect(service.pendingActionsBox.isOpen, isTrue);
      expect(Hive.isAdapterRegistered(0), isTrue);
      expect(Hive.isAdapterRegistered(1), isTrue);
    });

    test('clearAll removes all entries from both boxes', () async {
      await service.init(path: tempDir.path);

      const delivery = DeliveryEntity(
        id: 1,
        orderNumber: 'ORD-1',
        customerName: 'Test',
        phone: '123',
        address: 'Addr',
        amountDue: 10,
      );
      final action = DeliveryAction(
        clientActionId: 'act-1',
        deliveryId: 1,
        type: DeliveryActionType.complete,
        payload: const {},
        createdAt: DateTime.now(),
      );

      await service.deliveriesBox.put(delivery.id, delivery);
      await service.pendingActionsBox.put(action.clientActionId, action);

      expect(service.deliveriesBox.length, equals(1));
      expect(service.pendingActionsBox.length, equals(1));

      await service.clearAll();

      expect(service.deliveriesBox.isEmpty, isTrue);
      expect(service.pendingActionsBox.isEmpty, isTrue);
    });

    test('close closes both boxes and resets initialized state', () async {
      await service.init(path: tempDir.path);
      expect(service.isInitialized, isTrue);

      await service.close();

      expect(service.isInitialized, isFalse);
      expect(() => service.deliveriesBox, throwsStateError);
      expect(() => service.pendingActionsBox, throwsStateError);
    });
  });
}
