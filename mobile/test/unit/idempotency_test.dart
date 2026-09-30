import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/mapper/to_dto_mapper.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';

void main() {
  group('Idempotency Integrity', () {
    test('client_action_id remains byte-identical across retries and DTO conversions', () {
      final clientActionId = const Uuid().v4();

      final initialAction = DeliveryAction(
        clientActionId: clientActionId,
        deliveryId: 1001,
        type: DeliveryActionType.complete,
        payload: {
          NetworkConstants.keyRecipientName: 'Ahmed Ali',
          NetworkConstants.keyNote: 'Delivered safely',
          NetworkConstants.keyBaseVersion: 1,
        },
        status: SyncStatus.waitingToSync,
        createdAt: DateTime.now(),
        retryCount: 0,
      );

      final firstDto = initialAction.toCompleteRequestDto();
      expect(firstDto.clientActionId, clientActionId);

      // Simulate a network failure retry
      final retriedAction = initialAction.copyWith(
        retryCount: 1,
        status: SyncStatus.failed,
        lastError: 'Server 500 error',
      );

      final retryDto = retriedAction.toCompleteRequestDto();
      expect(retryDto.clientActionId, clientActionId);
      expect(retryDto.clientActionId, firstDto.clientActionId);

      // Simulate a third retry
      final secondRetryAction = retriedAction.copyWith(
        retryCount: 2,
        status: SyncStatus.failed,
      );

      final secondRetryDto = secondRetryAction.toCompleteRequestDto();
      expect(secondRetryDto.clientActionId, clientActionId);
    });

    test('failure action preserves client_action_id identically', () {
      final clientActionId = const Uuid().v4();

      final failAction = DeliveryAction(
        clientActionId: clientActionId,
        deliveryId: 1002,
        type: DeliveryActionType.fail,
        payload: {
          NetworkConstants.keyReason: FailureReason.wrongAddress.toApiKey(),
          NetworkConstants.keyNote: 'House not found',
        },
        status: SyncStatus.waitingToSync,
        createdAt: DateTime.now(),
        retryCount: 0,
      );

      final dto = failAction.toFailRequestDto();
      expect(dto.clientActionId, clientActionId);
      expect(dto.reason, 'wrong_address');

      final retriedFailAction = failAction.copyWith(retryCount: 1);
      final retriedDto = retriedFailAction.toFailRequestDto();
      expect(retriedDto.clientActionId, clientActionId);
    });
  });
}
