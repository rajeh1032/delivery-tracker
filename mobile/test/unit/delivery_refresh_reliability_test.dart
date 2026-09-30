import 'dart:async';
import 'dart:io';

import 'package:delivery_tracker/core/database/local_storage_service.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/repositories/delivery_repo_impl.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds_impl.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'sync_test_fixtures.dart';

class _Remote extends Mock implements DeliveryRemoteDs {}

void main() {
  late Directory tempDir;
  late LocalStorageService storage;
  late DeliveryLocalDataSource local;
  late _Remote remote;
  late DeliveryRepositoryImpl repository;

  final base = DeliveryEntity(
    id: 7,
    orderNumber: 'ORD-7',
    customerName: 'Sam',
    phone: '555',
    address: 'Town',
    amountDue: 10,
    status: DeliveryStatus.pending,
  );
  final server = refreshServer();
  DeliveryAction action(String id) => DeliveryAction(
    clientActionId: id,
    deliveryId: 7,
    type: DeliveryActionType.complete,
    payload: const {'recipient_name': 'Sam'},
    createdAt: DateTime.utc(2026),
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('refresh_reliability_');
    storage = LocalStorageService();
    await storage.init(path: tempDir.path);
    local = DeliveryLocalDataSourceImpl(storage);
    remote = _Remote();
    repository = DeliveryRepositoryImpl(local, remote);
  });
  tearDown(() async {
    await storage.close();
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test(
    'list refresh preserves waiting, syncing and failed queued deliveries',
    () async {
      for (final status in [
        SyncStatus.waitingToSync,
        SyncStatus.syncing,
        SyncStatus.failed,
        SyncStatus.synced,
      ]) {
        await local.clearAll();
        final queued = action('action-${status.name}');
        final optimistic = base.copyWith(
          status: DeliveryStatus.delivered,
          syncStatus: status,
          clientActionId: queued.clientActionId,
          recipientName: 'Sam',
        );
        await local.updateDelivery(optimistic);
        await local.savePendingAction(queued);
        when(
          () => remote.getDeliveries(),
        ).thenAnswer((_) async => ApiSuccessResult([server]));

        final result = await repository.getDeliveries();
        final effective = result.dataOrNull!.single;
        expect(effective.status, DeliveryStatus.delivered);
        expect(
          effective.syncStatus,
          status == SyncStatus.synced ? SyncStatus.waitingToSync : status,
        );
        expect(effective.clientActionId, queued.clientActionId);
        expect(effective.recipientName, 'Sam');
        expect(
          (await local.getDeliveryById(7))!.syncStatus,
          status == SyncStatus.synced ? SyncStatus.waitingToSync : status,
        );
        expect(await local.getPendingActions(), contains(queued));
      }
    },
  );

  test(
    'detail refresh preserves the optimistic state of a queued delivery',
    () async {
      for (final status in [
        SyncStatus.waitingToSync,
        SyncStatus.syncing,
        SyncStatus.failed,
      ]) {
        await local.clearAll();
        final queued = action('detail-${status.name}');
        final optimistic = base.copyWith(
          status: DeliveryStatus.delivered,
          syncStatus: status,
          clientActionId: queued.clientActionId,
          recipientName: 'Sam',
        );
        await local.updateDelivery(optimistic);
        await local.savePendingAction(queued);
        when(
          () => remote.getDeliveryById(7),
        ).thenAnswer((_) async => ApiSuccessResult(server));

        final result = await repository.getDeliveryById(7);
        expect(result.dataOrNull!.status, optimistic.status);
        expect(result.dataOrNull!.syncStatus, status);
        expect(result.dataOrNull!.clientActionId, queued.clientActionId);
      }
    },
  );

  test(
    'list refresh includes pending local deliveries and refreshes unqueued',
    () async {
      final queued = action('missing-from-server');
      final optimistic = base.copyWith(
        status: DeliveryStatus.delivered,
        syncStatus: SyncStatus.waitingToSync,
        clientActionId: queued.clientActionId,
        recipientName: 'Sam',
      );
      await local.updateDelivery(optimistic);
      await local.savePendingAction(queued);
      await local.updateDelivery(
        base.copyWith(id: 8, orderNumber: 'ORD-8', customerName: 'Old name'),
      );
      when(() => remote.getDeliveries()).thenAnswer(
        (_) async => ApiSuccessResult([
          DeliveryResponseDto(
            id: 8,
            orderNumber: 'ORD-8',
            customerName: 'Remote',
            phone: '8',
            address: 'Town',
            amountDue: 10,
            status: 'pending',
          ),
        ]),
      );

      final result = await repository.getDeliveries();
      expect(result.dataOrNull!.map((delivery) => delivery.id), contains(7));
      expect(
        (await local.getDeliveryById(7))!.syncStatus,
        SyncStatus.waitingToSync,
      );
      expect((await local.getDeliveryById(8))!.customerName, 'Remote');
    },
  );

  test(
    'action queued while list request waits survives the response',
    () async {
      final response = Completer<ApiResult<List<DeliveryResponseDto>>>();
      when(() => remote.getDeliveries()).thenAnswer((_) => response.future);
      final refresh = repository.getDeliveries();
      final queued = action('delayed-action');
      final optimistic = base.copyWith(
        status: DeliveryStatus.delivered,
        syncStatus: SyncStatus.waitingToSync,
        clientActionId: queued.clientActionId,
        recipientName: 'Sam',
      );
      await local.savePendingAction(queued);
      await local.updateDelivery(optimistic);
      response.complete(ApiSuccessResult([server]));

      final result = await refresh;
      expect(result.dataOrNull!.single.syncStatus, SyncStatus.waitingToSync);
      expect(result.dataOrNull!.single.clientActionId, queued.clientActionId);
      expect(await local.getPendingActions(), contains(queued));
      expect(
        (await local.getDeliveryById(7))!.clientActionId,
        queued.clientActionId,
      );
    },
  );
}
