import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryEntity', () {
    const entity = DeliveryEntity(
      id: 1001,
      orderNumber: 'ORD-1001',
      customerName: 'Ahmed Ali',
      phone: '55512345',
      address: 'Salmiya, Block 4, Street 12',
      amountDue: 18.75,
      paymentMethod: 'cash',
      status: DeliveryStatus.pending,
      syncStatus: SyncStatus.synced,
    );

    test('value equality based on Equatable', () {
      const identicalEntity = DeliveryEntity(
        id: 1001,
        orderNumber: 'ORD-1001',
        customerName: 'Ahmed Ali',
        phone: '55512345',
        address: 'Salmiya, Block 4, Street 12',
        amountDue: 18.75,
        paymentMethod: 'cash',
        status: DeliveryStatus.pending,
        syncStatus: SyncStatus.synced,
      );

      expect(entity, equals(identicalEntity));
      expect(entity.hashCode, equals(identicalEntity.hashCode));
    });

    test('getters correctly reflect status', () {
      expect(entity.isPending, isTrue);
      expect(entity.isDelivered, isFalse);
      expect(entity.isFailed, isFalse);
      expect(entity.isSynced, isTrue);
      expect(entity.isWaitingToSync, isFalse);
    });

    test('copyWith produces updated instance without modifying original', () {
      final updated = entity.copyWith(
        status: DeliveryStatus.delivered,
        recipientName: 'Ali Ahmed',
        syncStatus: SyncStatus.waitingToSync,
        version: 2,
      );

      expect(updated.id, 1001);
      expect(updated.status, DeliveryStatus.delivered);
      expect(updated.recipientName, 'Ali Ahmed');
      expect(updated.syncStatus, SyncStatus.waitingToSync);
      expect(updated.version, 2);
      expect(updated.isDelivered, isTrue);
      expect(updated.isWaitingToSync, isTrue);

      // Original remains unchanged
      expect(entity.status, DeliveryStatus.pending);
      expect(entity.recipientName, isNull);
    });
  });
}
