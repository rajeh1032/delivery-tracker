import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/complete_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/fail_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/complete_delivery_use_case.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/fail_delivery_use_case.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/get_deliveries_use_case.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/get_delivery_by_id_use_case.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/retry_action_use_case.dart';

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

void main() {
  late MockDeliveryRepository mockRepository;
  late GetDeliveriesUseCase getDeliveriesUseCase;
  late GetDeliveryByIdUseCase getDeliveryByIdUseCase;
  late CompleteDeliveryUseCase completeDeliveryUseCase;
  late FailDeliveryUseCase failDeliveryUseCase;
  late RetryActionUseCase retryActionUseCase;

  final tDelivery = DeliveryEntity(
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

  setUp(() {
    mockRepository = MockDeliveryRepository();
    getDeliveriesUseCase = GetDeliveriesUseCase(mockRepository);
    getDeliveryByIdUseCase = GetDeliveryByIdUseCase(mockRepository);
    completeDeliveryUseCase = CompleteDeliveryUseCase(mockRepository);
    failDeliveryUseCase = FailDeliveryUseCase(mockRepository);
    retryActionUseCase = RetryActionUseCase(mockRepository);
  });

  test('GetDeliveriesUseCase calls repository.getDeliveries()', () async {
    when(() => mockRepository.getDeliveries())
        .thenAnswer((_) async => ApiSuccessResult([tDelivery]));

    final result = await getDeliveriesUseCase.invoke();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, [tDelivery]);
    verify(() => mockRepository.getDeliveries()).called(1);
  });

  test('GetDeliveryByIdUseCase calls repository.getDeliveryById(id)', () async {
    when(() => mockRepository.getDeliveryById(1))
        .thenAnswer((_) async => ApiSuccessResult(tDelivery));

    final result = await getDeliveryByIdUseCase.invoke(1);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, tDelivery);
    verify(() => mockRepository.getDeliveryById(1)).called(1);
  });

  test('CompleteDeliveryUseCase calls repository.completeDelivery(request)',
      () async {
    const request = CompleteDeliveryRequestEntity(
      deliveryId: 1,
      recipientName: 'Ali',
      clientActionId: 'action-uuid-1',
    );

    when(() => mockRepository.completeDelivery(request))
        .thenAnswer((_) async => ApiSuccessResult(tDelivery));

    final result = await completeDeliveryUseCase.invoke(request);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, tDelivery);
    verify(() => mockRepository.completeDelivery(request)).called(1);
  });

  test('FailDeliveryUseCase calls repository.failDelivery(request)', () async {
    const request = FailDeliveryRequestEntity(
      deliveryId: 1,
      reason: FailureReason.customerUnavailable,
      clientActionId: 'action-uuid-2',
    );

    when(() => mockRepository.failDelivery(request))
        .thenAnswer((_) async => ApiSuccessResult(tDelivery));

    final result = await failDeliveryUseCase.invoke(request);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, tDelivery);
    verify(() => mockRepository.failDelivery(request)).called(1);
  });

  test('RetryActionUseCase calls repository.submitAction(action)', () async {
    final action = DeliveryAction(
      clientActionId: 'action-uuid-3',
      deliveryId: 1,
      type: DeliveryActionType.complete,
      payload: const {},
      status: SyncStatus.waitingToSync,
      createdAt: DateTime.now(),
    );

    when(() => mockRepository.submitAction(action))
        .thenAnswer((_) async {});

    await retryActionUseCase.invoke(action);

    verify(() => mockRepository.submitAction(action)).called(1);
  });
}
