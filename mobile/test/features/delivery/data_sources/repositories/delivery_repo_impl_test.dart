import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/repositories/delivery_repo_impl.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/complete_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/fail_delivery_request_entity.dart';

class MockDeliveryLocalDataSource extends Mock
    implements DeliveryLocalDataSource {}

class MockDeliveryRemoteDs extends Mock implements DeliveryRemoteDs {}

void main() {
  late MockDeliveryLocalDataSource mockLocalDs;
  late MockDeliveryRemoteDs mockRemoteDs;
  late DeliveryRepositoryImpl repository;

  final tDeliveryEntity = DeliveryEntity(
    id: 1,
    orderNumber: 'ORD-1001',
    customerName: 'Ahmed Rajeh',
    phone: '+96550000000',
    address: 'Kuwait City',
    amountDue: 15.5,
    paymentMethod: 'cash',
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.synced,
    version: 1,
  );

  final tDeliveryDto = DeliveryResponseDto(
    id: 1,
    orderNumber: 'ORD-1001',
    customerName: 'Ahmed Rajeh',
    phone: '+96550000000',
    address: 'Kuwait City',
    amountDue: 15.5,
    paymentMethod: 'cash',
    status: 'pending',
    version: 1,
  );

  setUp(() {
    mockLocalDs = MockDeliveryLocalDataSource();
    mockRemoteDs = MockDeliveryRemoteDs();
    repository = DeliveryRepositoryImpl(mockLocalDs, mockRemoteDs);
    registerFallbackValue(tDeliveryEntity);
    registerFallbackValue(
      DeliveryAction(
        clientActionId: 'fallback',
        deliveryId: 1,
        type: DeliveryActionType.complete,
        payload: const {},
        status: SyncStatus.waitingToSync,
        createdAt: DateTime.now(),
      ),
    );
  });

  group('getDeliveries', () {
    test('fetches from remote, updates local cache, and returns success',
        () async {
      when(() => mockRemoteDs.getDeliveries())
          .thenAnswer((_) async => ApiSuccessResult([tDeliveryDto]));
      when(() => mockLocalDs.cacheDeliveries(any()))
          .thenAnswer((_) async {});

      final result = await repository.getDeliveries();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, 1);
      expect(result.dataOrNull?.first.id, 1);
      verify(() => mockRemoteDs.getDeliveries()).called(1);
      verify(() => mockLocalDs.cacheDeliveries(any())).called(1);
    });

    test('falls back to local cache when remote fails and cache is not empty',
        () async {
      when(() => mockRemoteDs.getDeliveries()).thenAnswer(
        (_) async => const ApiErrorResult(
          'Network error',
          failure: TransientFailure(errorMessage: 'Network error'),
        ),
      );
      when(() => mockLocalDs.getDeliveries())
          .thenAnswer((_) async => [tDeliveryEntity]);

      final result = await repository.getDeliveries();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.length, 1);
      verify(() => mockLocalDs.getDeliveries()).called(1);
    });

    test('returns remote error when remote fails and local cache is empty',
        () async {
      when(() => mockRemoteDs.getDeliveries()).thenAnswer(
        (_) async => const ApiErrorResult(
          'Network error',
          failure: TransientFailure(errorMessage: 'Network error'),
        ),
      );
      when(() => mockLocalDs.getDeliveries()).thenAnswer((_) async => []);

      final result = await repository.getDeliveries();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.errorMessage, 'Network error');
    });
  });

  group('getDeliveryById', () {
    test('fetches from remote, updates local cache, and returns success',
        () async {
      when(() => mockLocalDs.getDeliveryById(1)).thenAnswer((_) async => null);
      when(() => mockRemoteDs.getDeliveryById(1))
          .thenAnswer((_) async => ApiSuccessResult(tDeliveryDto));
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});

      final result = await repository.getDeliveryById(1);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, 1);
      verify(() => mockLocalDs.updateDelivery(any())).called(1);
    });

    test('falls back to cached delivery when remote fails', () async {
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => tDeliveryEntity);
      when(() => mockRemoteDs.getDeliveryById(1)).thenAnswer(
        (_) async => const ApiErrorResult(
          'Offline',
          failure: TransientFailure(errorMessage: 'Offline'),
        ),
      );

      final result = await repository.getDeliveryById(1);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, 1);
    });
  });

  group('submitAction, completeDelivery, and failDelivery', () {
    test('submitAction saves pending action and mutates cached delivery',
        () async {
      when(() => mockLocalDs.savePendingAction(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => tDeliveryEntity);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});

      final action = DeliveryAction(
        clientActionId: 'action-uuid-1',
        deliveryId: 1,
        type: DeliveryActionType.complete,
        payload: const {NetworkConstants.keyRecipientName: 'Ali'},
        status: SyncStatus.waitingToSync,
        createdAt: DateTime.now(),
      );

      await repository.submitAction(action);

      verify(() => mockLocalDs.savePendingAction(action)).called(1);
      verify(() => mockLocalDs.updateDelivery(any(that: predicate<DeliveryEntity>((e) {
            return e.status == DeliveryStatus.delivered &&
                e.syncStatus == SyncStatus.waitingToSync &&
                e.clientActionId == 'action-uuid-1';
          })))).called(1);
    });

    test('completeDelivery stores action and returns updated delivery',
        () async {
      final updatedDelivery = tDeliveryEntity.copyWith(
        status: DeliveryStatus.delivered,
        syncStatus: SyncStatus.waitingToSync,
        clientActionId: 'action-uuid-2',
      );

      when(() => mockLocalDs.savePendingAction(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => updatedDelivery);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});

      const request = CompleteDeliveryRequestEntity(
        deliveryId: 1,
        recipientName: 'Omar',
        clientActionId: 'action-uuid-2',
      );

      final result = await repository.completeDelivery(request);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.status, DeliveryStatus.delivered);
      expect(result.dataOrNull?.syncStatus, SyncStatus.waitingToSync);
    });

    test('failDelivery stores action and returns updated delivery', () async {
      final updatedDelivery = tDeliveryEntity.copyWith(
        status: DeliveryStatus.failed,
        syncStatus: SyncStatus.waitingToSync,
        clientActionId: 'action-uuid-3',
      );

      when(() => mockLocalDs.savePendingAction(any()))
          .thenAnswer((_) async {});
      when(() => mockLocalDs.getDeliveryById(1))
          .thenAnswer((_) async => updatedDelivery);
      when(() => mockLocalDs.updateDelivery(any()))
          .thenAnswer((_) async {});

      const request = FailDeliveryRequestEntity(
        deliveryId: 1,
        reason: FailureReason.customerUnavailable,
        clientActionId: 'action-uuid-3',
      );

      final result = await repository.failDelivery(request);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.status, DeliveryStatus.failed);
      expect(result.dataOrNull?.syncStatus, SyncStatus.waitingToSync);
    });
  });

  test('watchDeliveries delegates directly to local data source stream', () {
    when(() => mockLocalDs.watchDeliveries())
        .thenAnswer((_) => Stream.value([tDeliveryEntity]));

    expect(repository.watchDeliveries(), emits([tDeliveryEntity]));
  });
}
