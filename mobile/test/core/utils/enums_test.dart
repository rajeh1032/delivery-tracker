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

    test('fromApiKeyOrNull returns null for null or invalid keys', () {
      expect(
        DeliveryStatus.fromApiKeyOrNull('delivered'),
        DeliveryStatus.delivered,
      );
      expect(
        DeliveryStatus.fromApiKeyOrNull('failed'),
        DeliveryStatus.failed,
      );
      expect(
        DeliveryStatus.fromApiKeyOrNull('pending'),
        DeliveryStatus.pending,
      );
      expect(DeliveryStatus.fromApiKeyOrNull(null), isNull);
      expect(DeliveryStatus.fromApiKeyOrNull(''), isNull);
      expect(DeliveryStatus.fromApiKeyOrNull('unknown'), isNull);
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

    test('fromApiKeyOrNull returns null for null or invalid keys', () {
      expect(
        DeliveryActionType.fromApiKeyOrNull('complete'),
        DeliveryActionType.complete,
      );
      expect(
        DeliveryActionType.fromApiKeyOrNull('fail'),
        DeliveryActionType.fail,
      );
      expect(DeliveryActionType.fromApiKeyOrNull(null), isNull);
      expect(DeliveryActionType.fromApiKeyOrNull(''), isNull);
      expect(DeliveryActionType.fromApiKeyOrNull('unknown'), isNull);
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

    test('fromApiKeyOrNull returns null for null, empty or non-failed values', () {
      expect(
        FailureReason.fromApiKeyOrNull('customer_unavailable'),
        FailureReason.customerUnavailable,
      );
      expect(
        FailureReason.fromApiKeyOrNull('wrong_address'),
        FailureReason.wrongAddress,
      );
      expect(
        FailureReason.fromApiKeyOrNull('customer_refused'),
        FailureReason.customerRefused,
      );
      expect(
        FailureReason.fromApiKeyOrNull('damaged_package'),
        FailureReason.damagedPackage,
      );
      expect(FailureReason.fromApiKeyOrNull('other'), FailureReason.other);
      expect(FailureReason.fromApiKeyOrNull('random_val'), FailureReason.other);
      expect(FailureReason.fromApiKeyOrNull(null), isNull);
      expect(FailureReason.fromApiKeyOrNull(''), isNull);
      expect(FailureReason.fromApiKeyOrNull('   '), isNull);
    });
  });
}
