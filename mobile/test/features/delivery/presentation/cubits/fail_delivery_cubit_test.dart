import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/fail_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/fail_delivery_use_case.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/fail_delivery/fail_delivery_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/fail_delivery/fail_delivery_state.dart';

class MockFailDeliveryUseCase extends Mock implements FailDeliveryUseCase {}

class MockSyncManager extends Mock implements SyncManager {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late MockFailDeliveryUseCase mockUseCase;
  late MockSyncManager mockSyncManager;
  late MockUuid mockUuid;

  const testActionId = 'fail-uuid-5678';
  const testDelivery = DeliveryEntity(
    id: 2,
    orderNumber: 'ORD-002',
    customerName: 'Sara',
    phone: '87654321',
    address: 'Hawally',
    amountDue: 20.0,
    paymentMethod: 'knet',
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.synced,
    version: 2,
  );

  setUpAll(() {
    registerFallbackValue(const FailDeliveryRequestEntity(
      deliveryId: 2,
      reason: FailureReason.customerUnavailable,
      clientActionId: testActionId,
      baseVersion: 2,
    ));
  });

  setUp(() {
    mockUseCase = MockFailDeliveryUseCase();
    mockSyncManager = MockSyncManager();
    mockUuid = MockUuid();

    when(() => mockUuid.v4()).thenReturn(testActionId);
    when(() => mockSyncManager.processQueue()).thenAnswer((_) async {});
  });

  FailDeliveryCubit buildCubit() => FailDeliveryCubit(
        mockUseCase,
        mockSyncManager,
        uuid: mockUuid,
      );

  group('FailDeliveryCubit', () {
    test('initial state has correct default values and clientActionId', () {
      final cubit = buildCubit();
      expect(cubit.state.clientActionId, testActionId);
      expect(cubit.state.reason, isNull);
      expect(cubit.state.note, isEmpty);
      expect(cubit.state.status, FailDeliveryStatus.editing);
    });

    test('reasonChanged and noteChanged update state', () {
      final cubit = buildCubit();
      cubit.reasonChanged(FailureReason.wrongAddress);
      cubit.noteChanged('Building not found');

      expect(cubit.state.reason, FailureReason.wrongAddress);
      expect(cubit.state.note, 'Building not found');
    });

    blocTest<FailDeliveryCubit, FailDeliveryState>(
      'confirm fails validation if reason is null',
      build: () => buildCubit(),
      act: (cubit) async {
        final ok = await cubit.confirm(testDelivery);
        expect(ok, isFalse);
      },
      expect: () => [
        const FailDeliveryState(
          clientActionId: testActionId,
          status: FailDeliveryStatus.failure,
          submissionError: 'Please select a failure reason',
        ),
      ],
    );

    blocTest<FailDeliveryCubit, FailDeliveryState>(
      'confirm invokes use case, emits success, and triggers sync',
      build: () {
        when(() => mockUseCase.invoke(any()))
            .thenAnswer((_) async => const ApiSuccessResult(testDelivery));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.reasonChanged(FailureReason.customerUnavailable);
        cubit.noteChanged('Phone switched off');
        final ok = await cubit.confirm(testDelivery);
        expect(ok, isTrue);
      },
      verify: (_) {
        verify(() => mockUseCase.invoke(any())).called(1);
        verify(() => mockSyncManager.processQueue()).called(1);
      },
      expect: () => [
        const FailDeliveryState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
        ),
        const FailDeliveryState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
          note: 'Phone switched off',
        ),
        const FailDeliveryState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
          note: 'Phone switched off',
          status: FailDeliveryStatus.submitting,
        ),
        const FailDeliveryState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
          note: 'Phone switched off',
          status: FailDeliveryStatus.success,
        ),
      ],
    );

    blocTest<FailDeliveryCubit, FailDeliveryState>(
      'confirm emits failure on ApiErrorResult',
      build: () {
        when(() => mockUseCase.invoke(any())).thenAnswer(
          (_) async => const ApiErrorResult('Submission rejected'),
        );
        return buildCubit();
      },
      act: (cubit) async {
        cubit.reasonChanged(FailureReason.damagedPackage);
        final ok = await cubit.confirm(testDelivery);
        expect(ok, isFalse);
      },
      expect: () => [
        const FailDeliveryState(
          clientActionId: testActionId,
          reason: FailureReason.damagedPackage,
        ),
        const FailDeliveryState(
          clientActionId: testActionId,
          reason: FailureReason.damagedPackage,
          status: FailDeliveryStatus.submitting,
        ),
        const FailDeliveryState(
          clientActionId: testActionId,
          reason: FailureReason.damagedPackage,
          status: FailDeliveryStatus.failure,
          submissionError: 'Submission rejected',
        ),
      ],
    );
  });
}
