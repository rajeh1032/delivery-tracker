import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryStatus', () {
    test('toApiKey returns expected strings', () {
      expect(DeliveryStatus.pending.toApiKey(), 'pending');
      expect(DeliveryStatus.delivered.toApiKey(), 'delivered');
      expect(DeliveryStatus.failed.toApiKey(), 'failed');
    });

    test('fromApiKey handles standard and unknown values', () {
      expect(DeliveryStatus.fromApiKey('delivered'), DeliveryStatus.delivered);
      expect(DeliveryStatus.fromApiKey('failed'), DeliveryStatus.failed);
      expect(DeliveryStatus.fromApiKey('pending'), DeliveryStatus.pending);
      expect(DeliveryStatus.fromApiKey('unknown'), DeliveryStatus.pending);
      expect(DeliveryStatus.fromApiKey(null), DeliveryStatus.pending);
    });
  });

  group('SyncStatus', () {
    test('isPendingSync flags waitingToSync and syncing', () {
      expect(SyncStatus.synced.isPendingSync, isFalse);
      expect(SyncStatus.waitingToSync.isPendingSync, isTrue);
      expect(SyncStatus.syncing.isPendingSync, isTrue);
      expect(SyncStatus.failed.isPendingSync, isFalse);
    });
  });

  group('DeliveryActionType', () {
    test('toApiKey returns correct values', () {
      expect(DeliveryActionType.complete.toApiKey(), 'complete');
      expect(DeliveryActionType.fail.toApiKey(), 'fail');
    });

    test('fromApiKey parses strings properly', () {
      expect(
        DeliveryActionType.fromApiKey('complete'),
        DeliveryActionType.complete,
      );
      expect(DeliveryActionType.fromApiKey('fail'), DeliveryActionType.fail);
      expect(DeliveryActionType.fromApiKey('unknown'), DeliveryActionType.fail);
      expect(DeliveryActionType.fromApiKey(null), DeliveryActionType.fail);
    });
  });

  group('FailureReason', () {
    test('toApiKey returns exact backend keys', () {
      expect(
        FailureReason.customerUnavailable.toApiKey(),
        'customer_unavailable',
      );
      expect(FailureReason.wrongAddress.toApiKey(), 'wrong_address');
      expect(FailureReason.customerRefused.toApiKey(), 'customer_refused');
      expect(FailureReason.damagedPackage.toApiKey(), 'damaged_package');
      expect(FailureReason.other.toApiKey(), 'other');
    });

    test('fromApiKey parses backend keys correctly', () {
      expect(
        FailureReason.fromApiKey('customer_unavailable'),
        FailureReason.customerUnavailable,
      );
      expect(
        FailureReason.fromApiKey('wrong_address'),
        FailureReason.wrongAddress,
      );
      expect(
        FailureReason.fromApiKey('customer_refused'),
        FailureReason.customerRefused,
      );
      expect(
        FailureReason.fromApiKey('damaged_package'),
        FailureReason.damagedPackage,
      );
      expect(FailureReason.fromApiKey('other'), FailureReason.other);
      expect(FailureReason.fromApiKey('random_val'), FailureReason.other);
      expect(FailureReason.fromApiKey(null), FailureReason.other);
    });
  });
}
