import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:delivery_tracker/core/database/local_storage_service.dart';
import 'package:delivery_tracker/core/utils/constants.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds_impl.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService storageService;
  late DeliveryLocalDataSource dataSource;

  final sampleDelivery1 = DeliveryEntity(
    id: 101,
    orderNumber: 'ORD-101',
    customerName: 'Ahmad Salem',
    phone: '+96590000001',
    address: 'Kuwait City, Block 1',
    amountDue: 25.500,
    paymentMethod: AppConstants.paymentMethodInstapay,
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.synced,
    version: 1,
    updatedAt: DateTime.utc(2026, 9, 29, 10, 0),
  );

  final sampleDelivery2 = DeliveryEntity(
    id: 102,
    orderNumber: 'ORD-102',
    customerName: 'Mona Al-Sabah',
    phone: '+96590000002',
    address: 'Hawally, Block 3',
    amountDue: 12.000,
    paymentMethod: 'cash',
    status: DeliveryStatus.delivered,
    syncStatus: SyncStatus.waitingToSync,
    recipientName: 'Mona Al-Sabah',
    clientActionId: 'action-uuid-102',
    version: 2,
    updatedAt: DateTime.utc(2026, 9, 29, 11, 0),
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('delivery_local_ds_test_');
    storageService = LocalStorageService();
    await storageService.init(path: tempDir.path);
    dataSource = DeliveryLocalDataSourceImpl(storageService);
  });

  tearDown(() async {
    if (storageService.isInitialized) {
      await storageService.close();
    }
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('DeliveryLocalDataSource - Deliveries Caching', () {
    test('cacheDeliveries and getDeliveries store and retrieve records', () async {
      await dataSource.cacheDeliveries([sampleDelivery1, sampleDelivery2]);

      final cached = await dataSource.getDeliveries();
      expect(cached.length, equals(2));
      expect(cached, contains(sampleDelivery1));
      expect(cached, contains(sampleDelivery2));
    });

    test('getDeliveryById returns entity when exists, null otherwise', () async {
      await dataSource.cacheDeliveries([sampleDelivery1]);

      final found = await dataSource.getDeliveryById(101);
      final notFound = await dataSource.getDeliveryById(999);

      expect(found, equals(sampleDelivery1));
      expect(notFound, isNull);
    });

    test('updateDelivery modifies existing record in place', () async {
      await dataSource.cacheDeliveries([sampleDelivery1]);

      final updated = sampleDelivery1.copyWith(
        status: DeliveryStatus.delivered,
        recipientName: 'Ahmad Brother',
        syncStatus: SyncStatus.waitingToSync,
        version: 2,
      );
      await dataSource.updateDelivery(updated);

      final fetched = await dataSource.getDeliveryById(101);
      expect(fetched, equals(updated));
      expect(fetched!.status, equals(DeliveryStatus.delivered));
      expect(fetched.recipientName, equals('Ahmad Brother'));
    });
  });

  group('DeliveryLocalDataSource - Offline Action Queue', () {
    test('savePendingAction persists action and getPendingActions returns FIFO', () async {
      final action1 = DeliveryAction(
        clientActionId: 'action-first',
        deliveryId: 101,
        type: DeliveryActionType.complete,
        payload: const {'recipient_name': 'First'},
        createdAt: DateTime.utc(2026, 9, 29, 10, 0),
      );
      final action2 = DeliveryAction(
        clientActionId: 'action-second',
        deliveryId: 102,
        type: DeliveryActionType.fail,
        payload: const {'reason': 'customer_unavailable'},
        createdAt: DateTime.utc(2026, 9, 29, 10, 5),
      );

      // Insert out of chronological order to verify FIFO sorting
      await dataSource.savePendingAction(action2);
      await dataSource.savePendingAction(action1);

      final queue = await dataSource.getPendingActions();
      expect(queue.length, equals(2));
      expect(queue.first.clientActionId, equals('action-first'));
      expect(queue.last.clientActionId, equals('action-second'));
    });

    test('deletePendingAction removes action by clientActionId', () async {
      final action = DeliveryAction(
        clientActionId: 'action-to-delete',
        deliveryId: 101,
        type: DeliveryActionType.complete,
        payload: const {},
        createdAt: DateTime.now(),
      );

      await dataSource.savePendingAction(action);
      expect((await dataSource.getPendingActions()).length, equals(1));

      await dataSource.deletePendingAction('action-to-delete');
      expect((await dataSource.getPendingActions()).isEmpty, isTrue);
    });
  });

  group('DeliveryLocalDataSource - Startup Reconciliation Invariant', () {
    test('resets stranded waitingToSync delivery to synced if no pending action exists', () async {
      // Delivery has waitingToSync status, but no corresponding action in pending queue
      final strandedDelivery = sampleDelivery1.copyWith(
        syncStatus: SyncStatus.waitingToSync,
        clientActionId: 'stranded-action-id',
      );
      await dataSource.cacheDeliveries([strandedDelivery]);

      final reconciledCount = await dataSource.reconcileStrandedSyncStates();
      expect(reconciledCount, equals(1));

      final restored = await dataSource.getDeliveryById(101);
      expect(restored!.syncStatus, equals(SyncStatus.synced));
    });

    test('preserves waitingToSync status if matching pending action exists in queue', () async {
      final pendingDelivery = sampleDelivery1.copyWith(
        syncStatus: SyncStatus.waitingToSync,
        clientActionId: 'valid-pending-action',
      );
      final validAction = DeliveryAction(
        clientActionId: 'valid-pending-action',
        deliveryId: 101,
        type: DeliveryActionType.complete,
        payload: const {'recipient_name': 'Salem'},
        createdAt: DateTime.now(),
      );

      await dataSource.cacheDeliveries([pendingDelivery]);
      await dataSource.savePendingAction(validAction);

      final reconciledCount = await dataSource.reconcileStrandedSyncStates();
      expect(reconciledCount, equals(0));

      final restored = await dataSource.getDeliveryById(101);
      expect(restored!.syncStatus, equals(SyncStatus.waitingToSync));
    });

    test('leaves already synced deliveries untouched', () async {
      await dataSource.cacheDeliveries([sampleDelivery1]);

      final count = await dataSource.reconcileStrandedSyncStates();
      expect(count, equals(0));

      final fetched = await dataSource.getDeliveryById(101);
      expect(fetched!.syncStatus, equals(SyncStatus.synced));
    });
  });

  group('DeliveryLocalDataSource - Process Death & Persistence Simulation', () {
    test('survives simulated process death and reloads data seamlessly', () async {
      await dataSource.cacheDeliveries([sampleDelivery1, sampleDelivery2]);
      final action = DeliveryAction(
        clientActionId: 'persist-action-1',
        deliveryId: 102,
        type: DeliveryActionType.complete,
        payload: const {'recipient_name': 'Mona'},
        createdAt: DateTime.utc(2026, 9, 29, 12, 0),
      );
      await dataSource.savePendingAction(action);

      // Simulate process death: close storage and clear Hive runtime memory
      await storageService.close();
      await Hive.close();

      // Simulate app relaunch: new service and datasource instance pointing to same directory
      final restartedService = LocalStorageService();
      await restartedService.init(path: tempDir.path);
      final restartedDataSource = DeliveryLocalDataSourceImpl(restartedService);

      final reloadedDeliveries = await restartedDataSource.getDeliveries();
      final reloadedActions = await restartedDataSource.getPendingActions();

      expect(reloadedDeliveries.length, equals(2));
      expect(reloadedDeliveries, contains(sampleDelivery1));
      expect(reloadedDeliveries, contains(sampleDelivery2));

      expect(reloadedActions.length, equals(1));
      expect(reloadedActions.first.clientActionId, equals('persist-action-1'));
      expect(reloadedActions.first.deliveryId, equals(102));

      await restartedService.close();
    });
  });

  group('DeliveryLocalDataSource - Reactive Stream & Clear', () {
    test('watchDeliveries emits current deliveries and subsequent updates', () async {
      final emittedLists = <List<DeliveryEntity>>[];
      final subscription = dataSource.watchDeliveries().listen(emittedLists.add);

      // Allow microtask to yield initial snapshot
      await Future<void>.delayed(Duration.zero);
      expect(emittedLists.length, equals(1));
      expect(emittedLists.first, isEmpty);

      // Insert single delivery
      await dataSource.updateDelivery(sampleDelivery1);
      await Future<void>.delayed(Duration.zero);
      expect(emittedLists.last.length, equals(1));
      expect(emittedLists.last.first.id, equals(101));

      // Insert second delivery
      await dataSource.updateDelivery(sampleDelivery2);
      await Future<void>.delayed(Duration.zero);
      expect(emittedLists.last.length, equals(2));

      await subscription.cancel();
    });

    test('clearAll clears deliveries and actions', () async {
      await dataSource.cacheDeliveries([sampleDelivery1]);
      await dataSource.savePendingAction(
        DeliveryAction(
          clientActionId: 'act-1',
          deliveryId: 101,
          type: DeliveryActionType.complete,
          payload: const {},
          createdAt: DateTime.now(),
        ),
      );

      expect((await dataSource.getDeliveries()).length, equals(1));
      expect((await dataSource.getPendingActions()).length, equals(1));

      await dataSource.clearAll();

      expect((await dataSource.getDeliveries()).isEmpty, isTrue);
      expect((await dataSource.getPendingActions()).isEmpty, isTrue);
    });
  });
}
