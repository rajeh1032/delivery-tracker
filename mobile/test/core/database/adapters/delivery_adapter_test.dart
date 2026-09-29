import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:delivery_tracker/core/database/adapters/delivery_adapter.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';

void main() {
  late Directory tempDir;
  late DeliveryAdapter adapter;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('delivery_adapter_test_');
    Hive.init(tempDir.path);
    adapter = DeliveryAdapter();
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

  group('DeliveryAdapter', () {
    test('has correct typeId 0', () {
      expect(adapter.typeId, equals(0));
    });

    test('serializes and deserializes fully populated DeliveryEntity', () async {
      final box = await Hive.openBox<DeliveryEntity>('test_delivery_box');
      final original = DeliveryEntity(
        id: 101,
        orderNumber: 'ORD-1001',
        customerName: 'Ahmad Salem',
        phone: '+96590000001',
        address: 'Kuwait City, Block 1, Street 2, Building 3',
        amountDue: 24.500,
        paymentMethod: 'knet',
        status: DeliveryStatus.delivered,
        syncStatus: SyncStatus.synced,
        recipientName: 'Mona Salem',
        failureReason: null,
        note: 'Delivered at front door',
        proofUrl: 'https://cdn.example.com/proofs/101.jpg',
        clientActionId: 'action-uuid-101',
        version: 2,
        updatedAt: DateTime.utc(2026, 9, 29, 12, 30),
      );

      await box.put(original.id, original);
      final restored = box.get(original.id);

      expect(restored, isNotNull);
      expect(restored!.id, equals(original.id));
      expect(restored.orderNumber, equals(original.orderNumber));
      expect(restored.customerName, equals(original.customerName));
      expect(restored.phone, equals(original.phone));
      expect(restored.address, equals(original.address));
      expect(restored.amountDue, equals(original.amountDue));
      expect(restored.paymentMethod, equals(original.paymentMethod));
      expect(restored.status, equals(DeliveryStatus.delivered));
      expect(restored.syncStatus, equals(SyncStatus.synced));
      expect(restored.recipientName, equals('Mona Salem'));
      expect(restored.failureReason, isNull);
      expect(restored.note, equals('Delivered at front door'));
      expect(restored.proofUrl, equals('https://cdn.example.com/proofs/101.jpg'));
      expect(restored.clientActionId, equals('action-uuid-101'));
      expect(restored.version, equals(2));
      expect(restored.updatedAt, equals(DateTime.utc(2026, 9, 29, 12, 30)));
    });

    test('serializes and deserializes failed DeliveryEntity with failureReason', () async {
      final box = await Hive.openBox<DeliveryEntity>('test_delivery_failed_box');
      final failedDelivery = DeliveryEntity(
        id: 102,
        orderNumber: 'ORD-1002',
        customerName: 'Fatima Ali',
        phone: '+96590000002',
        address: 'Salmiya, Block 5',
        amountDue: 15.000,
        paymentMethod: 'cash',
        status: DeliveryStatus.failed,
        syncStatus: SyncStatus.waitingToSync,
        failureReason: FailureReason.customerUnavailable,
        note: 'Customer did not pick up phone after 3 calls',
        version: 1,
      );

      await box.put(failedDelivery.id, failedDelivery);
      final restored = box.get(failedDelivery.id);

      expect(restored, isNotNull);
      expect(restored!.status, equals(DeliveryStatus.failed));
      expect(restored.syncStatus, equals(SyncStatus.waitingToSync));
      expect(restored.failureReason, equals(FailureReason.customerUnavailable));
      expect(restored.recipientName, isNull);
      expect(restored.proofUrl, isNull);
      expect(restored.updatedAt, isNull);
    });
  });
}
