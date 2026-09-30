import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/sync_queue/sync_queue_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/sync_queue/sync_queue_state.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

class MockSyncManager extends Mock implements SyncManager {}

void main() {
  late MockDeliveryRepository mockDeliveryRepository;
  late MockSyncManager mockSyncManager;
  late StreamController<List<DeliveryAction>> actionsStreamController;

  final testPendingAction = DeliveryAction(
    clientActionId: 'action-1',
    deliveryId: 101,
    type: DeliveryActionType.complete,
    payload: const {'recipient_name': 'Ali'},
    status: SyncStatus.waitingToSync,
    createdAt: DateTime(2026, 1, 1),
  );

  final testFailedAction = DeliveryAction(
    clientActionId: 'action-2',
    deliveryId: 102,
    type: DeliveryActionType.fail,
    payload: const {'reason': 'wrong_address'},
    status: SyncStatus.failed,
    lastError: 'HTTP 500 Server Error',
    retryCount: 1,
    createdAt: DateTime(2026, 1, 2),
  );

  setUp(() {
    mockDeliveryRepository = MockDeliveryRepository();
    mockSyncManager = MockSyncManager();
    actionsStreamController =
        StreamController<List<DeliveryAction>>.broadcast();

    when(() => mockDeliveryRepository.watchPendingActions())
        .thenAnswer((_) => actionsStreamController.stream);
    when(() => mockSyncManager.retryAction(any()))
        .thenAnswer((_) async => true);
    when(() => mockSyncManager.processQueue()).thenAnswer((_) async {});
  });

  tearDown(() {
    actionsStreamController.close();
  });

  SyncQueueCubit buildCubit() =>
      SyncQueueCubit(mockDeliveryRepository, mockSyncManager);

  group('SyncQueueCubit', () {
    test('initial state has empty actions and pending tab', () {
      final cubit = buildCubit();
      expect(cubit.state.actions, isEmpty);
      expect(cubit.state.tab, SyncQueueTab.pending);
      expect(cubit.state.isRetryingAll, isFalse);
      expect(cubit.state.retryingIds, isEmpty);
      cubit.close();
    });

    test('listens to watchPendingActions and updates state', () async {
      final cubit = buildCubit();

      actionsStreamController.add([testPendingAction, testFailedAction]);
      await pumpEventQueue();

      expect(cubit.state.actions.length, 2);
      expect(cubit.state.pendingCount, 1);
      expect(cubit.state.failedCount, 1);
      expect(cubit.state.visibleActions, [testPendingAction]);

      cubit.selectTab(SyncQueueTab.failed);
      expect(cubit.state.visibleActions, [testFailedAction]);

      await cubit.close();
    });

    blocTest<SyncQueueCubit, SyncQueueState>(
      'selectTab updates active tab',
      build: () => buildCubit(),
      act: (cubit) => cubit.selectTab(SyncQueueTab.failed),
      expect: () => [
        const SyncQueueState(tab: SyncQueueTab.failed),
      ],
    );

    blocTest<SyncQueueCubit, SyncQueueState>(
      'retryAction invokes syncManager.retryAction and tracks retryingIds',
      build: () => buildCubit(),
      act: (cubit) => cubit.retryAction('action-2'),
      verify: (_) {
        verify(() => mockSyncManager.retryAction('action-2')).called(1);
      },
      expect: () => [
        const SyncQueueState(retryingIds: {'action-2'}),
        const SyncQueueState(retryingIds: {}),
      ],
    );

    blocTest<SyncQueueCubit, SyncQueueState>(
      'retryAll sets isRetryingAll and invokes syncManager.processQueue',
      build: () => buildCubit(),
      act: (cubit) => cubit.retryAll(),
      verify: (_) {
        verify(() => mockSyncManager.processQueue()).called(1);
      },
      expect: () => [
        const SyncQueueState(isRetryingAll: true),
        const SyncQueueState(isRetryingAll: false),
      ],
    );
  });
}
