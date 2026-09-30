import 'dart:io';

import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'sync_test_fixtures.dart';

class _Local extends Mock implements DeliveryLocalDataSource {}

class _Remote extends Mock implements DeliveryRemoteDs {}

class _Connectivity extends Mock implements ConnectivityService {}

class _Proofs extends Mock implements ProofStorageService {}

void main() {
  late _Local local;
  late _Remote remote;
  late _Connectivity connectivity;
  late SyncManager manager;
  late DeliveryAction action;
  late DeliveryEntity delivery;
  var queue = <DeliveryAction>[];
  var fetchCount = 0;

  setUpAll(() {
    registerFallbackValue(
      DeliveryEntity(
        id: 1,
        orderNumber: 'ORD-1',
        customerName: 'Sam',
        phone: '555',
        address: 'Town',
        amountDue: 10,
      ),
    );
    registerFallbackValue(
      DeliveryAction(
        clientActionId: 'fallback',
        deliveryId: 1,
        type: DeliveryActionType.complete,
        payload: const {},
        createdAt: DateTime.utc(2026),
      ),
    );
    registerFallbackValue(
      const CompleteDeliveryRequestDto(
        recipientName: 'Sam',
        clientActionId: 'fallback',
      ),
    );
  });
  setUp(() {
    local = _Local();
    remote = _Remote();
    connectivity = _Connectivity();
    manager = SyncManager(local, remote, connectivity, _Proofs());
    when(() => connectivity.checkReachability()).thenAnswer((_) async => true);
    action = DeliveryAction(
      clientActionId: 'conflict-action',
      deliveryId: 1,
      type: DeliveryActionType.complete,
      payload: const {NetworkConstants.keyRecipientName: 'Sam'},
      createdAt: DateTime.utc(2026),
    );
    queue = [action];
    delivery = DeliveryEntity(
      id: 1,
      orderNumber: 'ORD-1',
      customerName: 'Sam',
      phone: '555',
      address: 'Town',
      amountDue: 10,
      status: DeliveryStatus.delivered,
      syncStatus: SyncStatus.waitingToSync,
      version: 1,
    );
    fetchCount = 0;
    when(() => remote.completeDelivery(1, any())).thenAnswer(
      (_) async => const ApiErrorResult(
        'conflict',
        statusCode: 409,
        code: NetworkConstants.deliveryConflict,
      ),
    );
    when(() => local.getPendingActions()).thenAnswer((_) async => [...queue]);
    when(() => local.getDeliveryById(1)).thenAnswer((_) async => delivery);
    when(() => local.updateDelivery(any())).thenAnswer((call) async {
      delivery = call.positionalArguments.single as DeliveryEntity;
    });
    when(() => local.savePendingAction(any())).thenAnswer((call) async {
      queue = [call.positionalArguments.single as DeliveryAction];
    });
    when(() => local.deletePendingAction(any())).thenAnswer((_) async {
      queue = [];
    });
  });
  tearDown(() => manager.dispose());

  test(
    'failed conflict fetch keeps action and later reconciles server truth',
    () async {
      when(() => remote.getDeliveryById(1)).thenAnswer((_) async {
        fetchCount++;
        if (fetchCount == 1) {
          return const ApiErrorResult('timeout', statusCode: 500);
        }
        return ApiSuccessResult(
          syncDelivery(id: 1, status: 'failed', version: 9),
        );
      });

      await manager.processQueue();
      expect(queue.single.clientActionId, action.clientActionId);
      expect(queue.single.status, SyncStatus.failed);
      expect(delivery.syncStatus, SyncStatus.failed);

      expect(await manager.retryAction(action.clientActionId), isFalse);
      expect(queue, hasLength(1));
      queue = [queue.single.copyWith(nextRetryAt: DateTime.utc(2026))];
      expect(await manager.retryAction(action.clientActionId), isFalse);
      expect(queue, isEmpty);
      expect(delivery.status, DeliveryStatus.failed);
      expect(delivery.version, 9);
      expect(delivery.syncStatus, SyncStatus.synced);
    },
  );

  test(
    'cache failure during reconciliation never dequeues the action',
    () async {
      when(() => remote.getDeliveryById(1)).thenAnswer(
        (_) async =>
            ApiSuccessResult(syncDelivery(id: 1, status: 'failed', version: 9)),
      );
      when(() => local.updateDelivery(any())).thenAnswer((call) async {
        final next = call.positionalArguments.single as DeliveryEntity;
        if (next.version == 9) {
          throw FileSystemException('cache unavailable');
        }
        delivery = next;
      });

      await manager.processQueue();
      expect(queue.single.clientActionId, action.clientActionId);
      expect(queue.single.status, SyncStatus.failed);
      expect(delivery.syncStatus, SyncStatus.failed);
      verifyNever(() => local.deletePendingAction(action.clientActionId));
    },
  );

  test(
    'successful mutation cache failure keeps the action retryable',
    () async {
      when(
        () => remote.completeDelivery(1, any()),
      ).thenAnswer((_) async => ApiSuccessResult(syncSuccess(1)));
      when(() => local.updateDelivery(any())).thenAnswer((call) async {
        final next = call.positionalArguments.single as DeliveryEntity;
        if (next.version == 2) throw HiveError('cache unavailable');
        delivery = next;
      });

      await manager.processQueue();
      expect(queue.single.clientActionId, action.clientActionId);
      expect(queue.single.status, SyncStatus.failed);
      expect(delivery.syncStatus, SyncStatus.failed);
      verifyNever(() => local.deletePendingAction(action.clientActionId));
    },
  );
}
