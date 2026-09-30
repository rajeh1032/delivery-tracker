import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/complete_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/fail_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/complete_delivery_use_case.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/fail_delivery_use_case.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/delivery_action/delivery_action_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/delivery_action/delivery_action_state.dart';

class MockCompleteDeliveryUseCase extends Mock
    implements CompleteDeliveryUseCase {}

class MockFailDeliveryUseCase extends Mock implements FailDeliveryUseCase {}

class MockProofStorageService extends Mock implements ProofStorageService {}

class MockSyncManager extends Mock implements SyncManager {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late MockCompleteDeliveryUseCase mockCompleteUseCase;
  late MockFailDeliveryUseCase mockFailUseCase;
  late MockProofStorageService mockStorageService;
  late MockSyncManager mockSyncManager;
  late MockImagePicker mockImagePicker;
  late MockUuid mockUuid;

  const testActionId = 'action-uuid-1234';
  const testDelivery = DeliveryEntity(
    id: 1,
    orderNumber: 'ORD-001',
    customerName: 'Ahmad',
    phone: '12345678',
    address: 'Kuwait City',
    amountDue: 15.0,
    paymentMethod: 'cash',
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.synced,
    version: 1,
  );

  setUpAll(() {
    registerFallbackValue(const CompleteDeliveryRequestEntity(
      deliveryId: 1,
      recipientName: 'Recipient',
      clientActionId: testActionId,
      baseVersion: 1,
    ));
    registerFallbackValue(const FailDeliveryRequestEntity(
      deliveryId: 1,
      reason: FailureReason.customerUnavailable,
      clientActionId: testActionId,
      baseVersion: 1,
    ));
    registerFallbackValue(File('dummy.jpg'));
    registerFallbackValue(ImageSource.camera);
  });

  setUp(() {
    mockCompleteUseCase = MockCompleteDeliveryUseCase();
    mockFailUseCase = MockFailDeliveryUseCase();
    mockStorageService = MockProofStorageService();
    mockSyncManager = MockSyncManager();
    mockImagePicker = MockImagePicker();
    mockUuid = MockUuid();

    when(() => mockUuid.v4()).thenReturn(testActionId);
    when(() => mockSyncManager.processQueue()).thenAnswer((_) async {});
  });

  DeliveryActionCubit buildCubit() => DeliveryActionCubit(
        mockCompleteUseCase,
        mockFailUseCase,
        mockStorageService,
        mockSyncManager,
        imagePicker: mockImagePicker,
        uuid: mockUuid,
      );

  group('DeliveryActionCubit - Common & Fields', () {
    test('initial state has correct default values and clientActionId', () {
      final cubit = buildCubit();
      expect(cubit.state.clientActionId, testActionId);
      expect(cubit.state.recipientName, isEmpty);
      expect(cubit.state.reason, isNull);
      expect(cubit.state.photoPath, isNull);
      expect(cubit.state.status, DeliveryActionStatus.initial);
    });

    test('recipientNameChanged, reasonChanged, and noteChanged update state', () {
      final cubit = buildCubit();
      cubit.recipientNameChanged('Fatima');
      cubit.reasonChanged(FailureReason.wrongAddress);
      cubit.noteChanged('Gate code 1234');

      expect(cubit.state.recipientName, 'Fatima');
      expect(cubit.state.reason, FailureReason.wrongAddress);
      expect(cubit.state.note, 'Gate code 1234');
    });

    test('removePhoto clears photo from state', () {
      final cubit = buildCubit();
      cubit.emit(cubit.state.copyWith(photoPath: '/path/to/proof.jpg'));
      expect(cubit.state.hasPhoto, isTrue);

      cubit.removePhoto();
      expect(cubit.state.photoPath, isNull);
      expect(cubit.state.hasPhoto, isFalse);
    });

    blocTest<DeliveryActionCubit, DeliveryActionState>(
      'pickPhoto saves file durably and updates photoPath on success',
      build: () {
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => XFile('/temp/picked.jpg'));
        when(() => mockStorageService.saveProofFile(any(), testActionId))
            .thenAnswer((_) async => '/durable/proof.jpg');
        return buildCubit();
      },
      act: (cubit) => cubit.pickPhoto(ImageSource.camera),
      expect: () => [
        const DeliveryActionState(
          clientActionId: testActionId,
          status: DeliveryActionStatus.pickingPhoto,
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          status: DeliveryActionStatus.initial,
          photoPath: '/durable/proof.jpg',
        ),
      ],
    );
  });

  group('DeliveryActionCubit - Complete Delivery', () {
    blocTest<DeliveryActionCubit, DeliveryActionState>(
      'completeDelivery fails validation if recipientName is too short',
      build: () => buildCubit(),
      act: (cubit) async {
        cubit.recipientNameChanged(' ');
        final ok = await cubit.completeDelivery(testDelivery);
        expect(ok, isFalse);
      },
      expect: () => [
        const DeliveryActionState(
          clientActionId: testActionId,
          recipientName: ' ',
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          recipientName: ' ',
          status: DeliveryActionStatus.failure,
          actionType: DeliveryActionType.complete,
          errorMessage: 'Recipient name is required',
        ),
      ],
    );

    blocTest<DeliveryActionCubit, DeliveryActionState>(
      'completeDelivery invokes usecase, emits success, and triggers sync',
      build: () {
        when(() => mockCompleteUseCase.invoke(any()))
            .thenAnswer((_) async => const ApiSuccessResult(testDelivery));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.recipientNameChanged('Ali Hassan');
        cubit.noteChanged('Left at reception');
        final ok = await cubit.completeDelivery(testDelivery);
        expect(ok, isTrue);
      },
      verify: (_) {
        verify(() => mockCompleteUseCase.invoke(any())).called(1);
        verify(() => mockSyncManager.processQueue()).called(1);
      },
      expect: () => [
        const DeliveryActionState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
          note: 'Left at reception',
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
          note: 'Left at reception',
          status: DeliveryActionStatus.submitting,
          actionType: DeliveryActionType.complete,
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
          note: 'Left at reception',
          status: DeliveryActionStatus.success,
          actionType: DeliveryActionType.complete,
        ),
      ],
    );
  });

  group('DeliveryActionCubit - Fail Delivery', () {
    blocTest<DeliveryActionCubit, DeliveryActionState>(
      'failDelivery fails validation if reason is null',
      build: () => buildCubit(),
      act: (cubit) async {
        final ok = await cubit.failDelivery(testDelivery);
        expect(ok, isFalse);
      },
      expect: () => [
        const DeliveryActionState(
          clientActionId: testActionId,
          status: DeliveryActionStatus.failure,
          actionType: DeliveryActionType.fail,
          errorMessage: 'Please select a failure reason',
        ),
      ],
    );

    blocTest<DeliveryActionCubit, DeliveryActionState>(
      'failDelivery invokes usecase, emits success, and triggers sync',
      build: () {
        when(() => mockFailUseCase.invoke(any()))
            .thenAnswer((_) async => const ApiSuccessResult(testDelivery));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.reasonChanged(FailureReason.customerUnavailable);
        cubit.noteChanged('Phone switched off');
        final ok = await cubit.failDelivery(testDelivery);
        expect(ok, isTrue);
      },
      verify: (_) {
        verify(() => mockFailUseCase.invoke(any())).called(1);
        verify(() => mockSyncManager.processQueue()).called(1);
      },
      expect: () => [
        const DeliveryActionState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
          note: 'Phone switched off',
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
          note: 'Phone switched off',
          status: DeliveryActionStatus.submitting,
          actionType: DeliveryActionType.fail,
        ),
        const DeliveryActionState(
          clientActionId: testActionId,
          reason: FailureReason.customerUnavailable,
          note: 'Phone switched off',
          status: DeliveryActionStatus.success,
          actionType: DeliveryActionType.fail,
        ),
      ],
    );
  });
}
