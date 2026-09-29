import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/complete_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/fail_delivery_request_entity.dart';

void main() {
  group('CompleteDeliveryRequestEntity', () {
    test('supports value equality and props verification', () {
      const entity1 = CompleteDeliveryRequestEntity(
        deliveryId: 101,
        recipientName: 'Ahmed Rajeh',
        note: 'Left at reception',
        clientActionId: 'action-uuid-1',
        baseVersion: 2,
        localPhotoPath: '/path/to/proof.jpg',
      );

      const entity2 = CompleteDeliveryRequestEntity(
        deliveryId: 101,
        recipientName: 'Ahmed Rajeh',
        note: 'Left at reception',
        clientActionId: 'action-uuid-1',
        baseVersion: 2,
        localPhotoPath: '/path/to/proof.jpg',
      );

      const entityDifferent = CompleteDeliveryRequestEntity(
        deliveryId: 102,
        recipientName: 'Other Person',
        clientActionId: 'action-uuid-2',
      );

      expect(entity1, equals(entity2));
      expect(entity1 == entityDifferent, isFalse);
      expect(entity1.props, [
        101,
        'Ahmed Rajeh',
        'Left at reception',
        'action-uuid-1',
        2,
        '/path/to/proof.jpg',
      ]);
    });
  });

  group('FailDeliveryRequestEntity', () {
    test('supports value equality and props verification', () {
      const entity1 = FailDeliveryRequestEntity(
        deliveryId: 101,
        reason: FailureReason.customerUnavailable,
        note: 'Called 3 times',
        clientActionId: 'action-uuid-fail-1',
        baseVersion: 2,
      );

      const entity2 = FailDeliveryRequestEntity(
        deliveryId: 101,
        reason: FailureReason.customerUnavailable,
        note: 'Called 3 times',
        clientActionId: 'action-uuid-fail-1',
        baseVersion: 2,
      );

      const entityDifferent = FailDeliveryRequestEntity(
        deliveryId: 101,
        reason: FailureReason.wrongAddress,
        clientActionId: 'action-uuid-fail-2',
      );

      expect(entity1, equals(entity2));
      expect(entity1 == entityDifferent, isFalse);
      expect(entity1.props, [
        101,
        FailureReason.customerUnavailable,
        'Called 3 times',
        'action-uuid-fail-1',
        2,
      ]);
    });
  });
}
