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
import 'package:delivery_tracker/features/delivery/domain/use_case/complete_delivery_use_case.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/complete_delivery/complete_delivery_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/complete_delivery/complete_delivery_state.dart';

class MockCompleteDeliveryUseCase extends Mock
    implements CompleteDeliveryUseCase {}

class MockProofStorageService extends Mock implements ProofStorageService {}

class MockSyncManager extends Mock implements SyncManager {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late MockCompleteDeliveryUseCase mockUseCase;
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
    registerFallbackValue(File('dummy.jpg'));
    registerFallbackValue(ImageSource.camera);
  });

  setUp(() {
    mockUseCase = MockCompleteDeliveryUseCase();
    mockStorageService = MockProofStorageService();
    mockSyncManager = MockSyncManager();
    mockImagePicker = MockImagePicker();
    mockUuid = MockUuid();

    when(() => mockUuid.v4()).thenReturn(testActionId);
    when(() => mockSyncManager.processQueue()).thenAnswer((_) async {});
  });

  CompleteDeliveryCubit buildCubit() => CompleteDeliveryCubit(
        mockUseCase,
        mockStorageService,
        mockSyncManager,
        imagePicker: mockImagePicker,
        uuid: mockUuid,
      );

  group('CompleteDeliveryCubit', () {
    test('initial state has correct default values and clientActionId', () {
      final cubit = buildCubit();
      expect(cubit.state.clientActionId, testActionId);
      expect(cubit.state.recipientName, isEmpty);
      expect(cubit.state.photoPath, isNull);
      expect(cubit.state.status, CompleteDeliveryStatus.editing);
    });

    test('recipientNameChanged updates recipientName in state', () {
      final cubit = buildCubit();
      cubit.recipientNameChanged('Fatima');
      expect(cubit.state.recipientName, 'Fatima');
    });

    test('removePhoto clears photo from state', () {
      final cubit = buildCubit();
      cubit.emit(cubit.state.copyWith(photoPath: '/path/to/proof.jpg'));
      expect(cubit.state.hasPhoto, isTrue);

      cubit.removePhoto();
      expect(cubit.state.photoPath, isNull);
      expect(cubit.state.hasPhoto, isFalse);
    });

    blocTest<CompleteDeliveryCubit, CompleteDeliveryState>(
      'pickPhoto saves file durably and updates photoPath on success',
      build: () {
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => XFile('/temp/picked.jpg'));
        when(() => mockStorageService.saveProofFile(any(), testActionId))
            .thenAnswer((_) async => '/durable/proof.jpg');
        return buildCubit();
      },
      act: (cubit) => cubit.pickPhoto(ImageSource.camera),
      expect: () => [
        const CompleteDeliveryState(
          clientActionId: testActionId,
          status: CompleteDeliveryStatus.pickingPhoto,
        ),
        const CompleteDeliveryState(
          clientActionId: testActionId,
          status: CompleteDeliveryStatus.editing,
          photoPath: '/durable/proof.jpg',
        ),
      ],
    );

    blocTest<CompleteDeliveryCubit, CompleteDeliveryState>(
      'confirm fails validation if recipientName is too short',
      build: () => buildCubit(),
      act: (cubit) async {
        cubit.recipientNameChanged(' ');
        await cubit.confirm(testDelivery);
      },
      expect: () => [
        const CompleteDeliveryState(
          clientActionId: testActionId,
          recipientName: ' ',
        ),
        const CompleteDeliveryState(
          clientActionId: testActionId,
          recipientName: ' ',
          status: CompleteDeliveryStatus.failure,
          submissionError: 'Recipient name is required',
        ),
      ],
    );

    blocTest<CompleteDeliveryCubit, CompleteDeliveryState>(
      'confirm invokes use case, emits success, and triggers sync',
      build: () {
        when(() => mockUseCase.invoke(any()))
            .thenAnswer((_) async => const ApiSuccessResult(testDelivery));
        return buildCubit();
      },
      act: (cubit) async {
        cubit.recipientNameChanged('Ali Hassan');
        cubit.noteChanged('Left at reception');
        final ok = await cubit.confirm(testDelivery);
        expect(ok, isTrue);
      },
      verify: (_) {
        verify(() => mockUseCase.invoke(any())).called(1);
        verify(() => mockSyncManager.processQueue()).called(1);
      },
      expect: () => [
        const CompleteDeliveryState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
        ),
        const CompleteDeliveryState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
          note: 'Left at reception',
        ),
        const CompleteDeliveryState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
          note: 'Left at reception',
          status: CompleteDeliveryStatus.submitting,
        ),
        const CompleteDeliveryState(
          clientActionId: testActionId,
          recipientName: 'Ali Hassan',
          note: 'Left at reception',
          status: CompleteDeliveryStatus.success,
        ),
      ],
    );
  });
}
