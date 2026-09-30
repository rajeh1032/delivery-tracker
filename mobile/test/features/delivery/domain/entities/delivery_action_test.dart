import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryAction', () {
    final now = DateTime(2026, 9, 29, 12, 0, 0);
    final action = DeliveryAction(
      clientActionId: 'f0458688-6629-4592-aa49-f4aa6b88b1f8',
      deliveryId: 1001,
      type: DeliveryActionType.complete,
      payload: const {
        'recipient_name': 'Ali Ahmed',
        'note': 'Left with guard',
      },
      createdAt: now,
    );

    test('value equality based on Equatable', () {
      final sameAction = DeliveryAction(
        clientActionId: 'f0458688-6629-4592-aa49-f4aa6b88b1f8',
        deliveryId: 1001,
        type: DeliveryActionType.complete,
        payload: const {
          'recipient_name': 'Ali Ahmed',
          'note': 'Left with guard',
        },
        createdAt: now,
      );

      expect(action, equals(sameAction));
    });

    test('payloadJson serializes payload map to JSON string', () {
      expect(
        action.payloadJson,
        '{"recipient_name":"Ali Ahmed","note":"Left with guard"}',
      );
    });

    test('copyWith produces modified copy with updated retryCount and status', () {
      final updated = action.copyWith(
        status: SyncStatus.failed,
        retryCount: 1,
        lastError: 'HTTP 500: Server Error',
      );

      expect(updated.status, SyncStatus.failed);
      expect(updated.retryCount, 1);
      expect(updated.lastError, 'HTTP 500: Server Error');
      expect(updated.isFailed, isTrue);

      expect(action.status, SyncStatus.waitingToSync);
      expect(action.retryCount, 0);
      expect(action.lastError, isNull);
    });
  });
}
