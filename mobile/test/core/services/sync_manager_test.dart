import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/request/fail_delivery_request_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';

class MockDeliveryLocalDataSource extends Mock
    implements DeliveryLocalDataSource {}

class MockDeliveryRemoteDs extends Mock implements DeliveryRemoteDs {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockProofStorageService extends Mock implements ProofStorageService {}

void main() {
  late MockDeliveryLocalDataSource mockLocalDs;
  late MockDeliveryRemoteDs mockRemoteDs;
  late MockConnectivityService mockConnectivityService;
  late MockProofStorageService mockProofStorageService;
  late SyncManager syncManager;

  final tDeliveryEntity = DeliveryEntity(
    id: 1,
    orderNumber: 'ORD-1001',
    customerName: 'Ahmed Rajeh',
    phone: '+96550000000',
    address: 'Kuwait City',
    amountDue: 15.5,
    paymentMethod: 'cash',
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.waitingToSync,
    version: 1,
  );

  final tResponseDto = DeliveryResponseDto(
    id: 1,
    orderNumber: 'ORD-1001',
    customerName: 'Ahmed Rajeh',
    phone: '+96550000000',
    address: 'Kuwait City',
    amountDue: 15.5,
    paymentMethod: 'cash',
    status: 'delivered',
    version: 2,
  );

  final tActionResponseDto = DeliveryActionResponseDto(
    message: 'Success',
    delivery: tResponseDto,
  );

  final tCompleteAction = DeliveryAction(
    clientActionId: 'action-uuid-123',
    deliveryId: 1,
    type: DeliveryActionType.complete,
    payload: const {
      NetworkConstants.keyRecipientName: 'Ali',
      NetworkConstants.keyNote: 'Left at reception',
      NetworkConstants.keyBaseVersion: 1,
    },
    status: SyncStatus.waitingToSync,
    createdAt: DateTime.now(),
  );

  final tFailAction = DeliveryAction(
    clientActionId: 'action-uuid-456',
    deliveryId: 1,
    type: DeliveryActionType.fail,
    payload: const {
      NetworkConstants.keyReason: 'customer_unavailable',
      NetworkConstants.keyNote: 'Phone switched off',
      NetworkConstants.keyBaseVersion: 1,
    },
    status: SyncStatus.waitingToSync,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockLocalDs = MockDeliveryLocalDataSource();
    mockRemoteDs = MockDeliveryRemoteDs();
    mockConnectivityService = MockConnectivityService();
    mockProofStorageService = MockProofStorageService();

    syncManager = SyncManager(
      mockLocalDs,
      mockRemoteDs,
      mockConnectivityService,
      mockProofStorageService,
    );

    registerFallbackValue(tDeliveryEntity);
    registerFallbackValue(tCompleteAction);
    registerFallbackValue(
      const CompleteDeliveryRequestDto(
        recipientName: 'Ali',
        clientActionId: 'action-uuid-123',
      ),
    );
    registerFallbackValue(
      const FailDeliveryRequestDto(
        reason: 'customer_unavailable',
        clientActionId: 'action-uuid-456',
      ),
    );
  });

  tearDown(() {
    syncManager.dispose();
  });

  group('processQueue', () {
    test('does nothing when checkReachability returns false', () async {
      when(() => mockConnectivityService.checkReachability())
          .thenAnswer((_) async => false);

      await syncManager.processQueue();

      verify(() => mockConnectivityService.checkReachability()).called(1);
      verifyNever(() => mockLocalDs.getPendingActions());
    });

    test('synchronizes complete delivery action successfully', () async {
      when(() => mockConnectivityService.checkReachability())
          .thenAnswer((_) async => true);
      when(() => mockLocalDs.getPendingActions())
          .thenAnswer((_) async => [tCompleteAction]);
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => tDeliveryEntity);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.deletePendingAction(tCompleteAction.clientActionId))
          .thenAnswer((_) async {});
      when(() => mockRemoteDs.completeDelivery(1, any()))
          .thenAnswer((_) async => ApiSuccessResult(tActionResponseDto));

      await syncManager.processQueue();

      verify(() => mockRemoteDs.completeDelivery(1, any(
            that: predicate<CompleteDeliveryRequestDto>((dto) {
              return dto.clientActionId == tCompleteAction.clientActionId &&
                  dto.recipientName == 'Ali';
            }),
          ))).called(1);
      verify(() => mockLocalDs.deletePendingAction(tCompleteAction.clientActionId))
          .called(1);
      verify(() => mockLocalDs.updateDelivery(any(
            that: predicate<DeliveryEntity>((e) =>
                e.syncStatus == SyncStatus.synced &&
                e.status == DeliveryStatus.delivered),
          ))).called(1);
    });

    test('synchronizes fail delivery action successfully', () async {
      when(() => mockConnectivityService.checkReachability())
          .thenAnswer((_) async => true);
      when(() => mockLocalDs.getPendingActions())
          .thenAnswer((_) async => [tFailAction]);
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => tDeliveryEntity);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.deletePendingAction(tFailAction.clientActionId))
          .thenAnswer((_) async {});
      when(() => mockRemoteDs.failDelivery(1, any()))
          .thenAnswer((_) async => ApiSuccessResult(tActionResponseDto));

      await syncManager.processQueue();

      verify(() => mockRemoteDs.failDelivery(1, any(
            that: predicate<FailDeliveryRequestDto>((dto) {
              return dto.clientActionId == tFailAction.clientActionId &&
                  dto.reason == 'customer_unavailable';
            }),
          ))).called(1);
      verify(() => mockLocalDs.deletePendingAction(tFailAction.clientActionId))
          .called(1);
    });

    test('handles 409 conflict by fetching server state and deleting action',
        () async {
      when(() => mockConnectivityService.checkReachability())
          .thenAnswer((_) async => true);
      when(() => mockLocalDs.getPendingActions())
          .thenAnswer((_) async => [tCompleteAction]);
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => tDeliveryEntity);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.deletePendingAction(tCompleteAction.clientActionId))
          .thenAnswer((_) async {});
      when(() => mockRemoteDs.completeDelivery(1, any())).thenAnswer(
        (_) async => const ApiErrorResult(
          'Conflict',
          statusCode: 409,
          code: NetworkConstants.deliveryConflict,
        ),
      );
      when(() => mockRemoteDs.getDeliveryById(1))
          .thenAnswer((_) async => ApiSuccessResult(tResponseDto));

      await syncManager.processQueue();

      verify(() => mockRemoteDs.getDeliveryById(1)).called(1);
      verify(() => mockLocalDs.deletePendingAction(tCompleteAction.clientActionId))
          .called(1);
      verify(() => mockLocalDs.updateDelivery(any(
            that: predicate<DeliveryEntity>(
              (e) => e.syncStatus == SyncStatus.synced,
            ),
          ))).called(1);
    });

    test('handles 500 transient failure by incrementing retryCount', () async {
      when(() => mockConnectivityService.checkReachability())
          .thenAnswer((_) async => true);
      when(() => mockLocalDs.getPendingActions())
          .thenAnswer((_) async => [tCompleteAction]);
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => tDeliveryEntity);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.savePendingAction(any()))
          .thenAnswer((_) async {});
      when(() => mockRemoteDs.completeDelivery(1, any())).thenAnswer(
        (_) async => const ApiErrorResult(
          'Internal server error',
          statusCode: 500,
          failure: TransientFailure(errorMessage: 'Server 500'),
        ),
      );

      await syncManager.processQueue();

      verify(() => mockLocalDs.savePendingAction(any(
            that: predicate<DeliveryAction>((a) {
              return a.clientActionId == tCompleteAction.clientActionId &&
                  a.retryCount == 1 &&
                  a.status == SyncStatus.failed;
            }),
          ))).called(1);
      verify(() => mockLocalDs.updateDelivery(any(
            that: predicate<DeliveryEntity>(
              (e) => e.syncStatus == SyncStatus.failed,
            ),
          ))).called(1);
      verifyNever(() => mockLocalDs.deletePendingAction(any()));
    });
  });

  group('retryAction', () {
    test('retries specific pending action when found and reachable', () async {
      when(() => mockLocalDs.getPendingActions())
          .thenAnswer((_) async => [tCompleteAction]);
      when(() => mockConnectivityService.checkReachability())
          .thenAnswer((_) async => true);
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => tDeliveryEntity);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.deletePendingAction(tCompleteAction.clientActionId))
          .thenAnswer((_) async {});
      when(() => mockRemoteDs.completeDelivery(1, any()))
          .thenAnswer((_) async => ApiSuccessResult(tActionResponseDto));

      final success =
          await syncManager.retryAction(tCompleteAction.clientActionId);

      expect(success, isTrue);
      verify(() => mockRemoteDs.completeDelivery(1, any())).called(1);
    });

    test('returns false when action is not found in pending queue', () async {
      when(() => mockLocalDs.getPendingActions()).thenAnswer((_) async => []);

      final success = await syncManager.retryAction('non-existent');

      expect(success, isFalse);
      verifyNever(() => mockConnectivityService.checkReachability());
    });
  });
}
