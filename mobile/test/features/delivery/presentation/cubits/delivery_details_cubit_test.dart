import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/get_delivery_by_id_use_case.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/delivery_details/delivery_details_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/delivery_details/delivery_details_state.dart';

class MockGetDeliveryByIdUseCase extends Mock
    implements GetDeliveryByIdUseCase {}

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

void main() {
  late MockGetDeliveryByIdUseCase mockGetDeliveryByIdUseCase;
  late MockDeliveryRepository mockDeliveryRepository;
  late StreamController<List<DeliveryEntity>> watchStreamController;

  const testDelivery = DeliveryEntity(
    id: 101,
    orderNumber: 'ORD-101',
    customerName: 'Fatima Zahra',
    phone: '+965 9876 5432',
    address: 'Salmiya, Block 4, Street 12, Building 8',
    amountDue: 24.500,
    paymentMethod: 'cash',
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.synced,
  );

  setUp(() {
    mockGetDeliveryByIdUseCase = MockGetDeliveryByIdUseCase();
    mockDeliveryRepository = MockDeliveryRepository();
    watchStreamController = StreamController<List<DeliveryEntity>>.broadcast();

    when(() => mockDeliveryRepository.watchDeliveries())
        .thenAnswer((_) => watchStreamController.stream);
  });

  tearDown(() {
    watchStreamController.close();
  });

  DeliveryDetailsCubit buildCubit() {
    return DeliveryDetailsCubit(
      mockGetDeliveryByIdUseCase,
      mockDeliveryRepository,
    );
  }

  group('DeliveryDetailsCubit', () {
    test('initial state has initial status and null delivery', () async {
      final cubit = buildCubit();
      expect(cubit.state.status, DeliveryDetailsStatus.initial);
      expect(cubit.state.delivery, isNull);
      await cubit.close();
    });

    blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
      'loadDelivery with preloaded immediately emits loaded',
      build: () {
        when(() => mockGetDeliveryByIdUseCase.invoke(101))
            .thenAnswer((_) async => const ApiSuccessResult(testDelivery));
        return buildCubit();
      },
      act: (cubit) => cubit.loadDelivery(101, preloaded: testDelivery),
      expect: () => [
        const DeliveryDetailsState(
          status: DeliveryDetailsStatus.loaded,
          delivery: testDelivery,
        ),
      ],
    );

    blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
      'loadDelivery emits loading then loaded on ApiSuccessResult',
      build: () {
        when(() => mockGetDeliveryByIdUseCase.invoke(101))
            .thenAnswer((_) async => const ApiSuccessResult(testDelivery));
        return buildCubit();
      },
      act: (cubit) => cubit.loadDelivery(101),
      expect: () => [
        const DeliveryDetailsState(status: DeliveryDetailsStatus.loading),
        const DeliveryDetailsState(
          status: DeliveryDetailsStatus.loaded,
          delivery: testDelivery,
        ),
      ],
    );

    blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
      'loadDelivery emits notFound on 404 failure',
      build: () {
        when(() => mockGetDeliveryByIdUseCase.invoke(999)).thenAnswer(
          (_) async => const ApiErrorResult('Not Found', code: '404'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadDelivery(999),
      expect: () => [
        const DeliveryDetailsState(status: DeliveryDetailsStatus.loading),
        const DeliveryDetailsState(
          status: DeliveryDetailsStatus.notFound,
          errorMessage: 'Not Found',
        ),
      ],
    );

    blocTest<DeliveryDetailsCubit, DeliveryDetailsState>(
      'loadDelivery emits error on generic failure',
      build: () {
        when(() => mockGetDeliveryByIdUseCase.invoke(101)).thenAnswer(
          (_) async => const ApiErrorResult('Network error', code: '500'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadDelivery(101),
      expect: () => [
        const DeliveryDetailsState(status: DeliveryDetailsStatus.loading),
        const DeliveryDetailsState(
          status: DeliveryDetailsStatus.error,
          errorMessage: 'Network error',
        ),
      ],
    );

    test('watchDeliveries updates delivery when cache changes', () async {
      when(() => mockGetDeliveryByIdUseCase.invoke(101))
          .thenAnswer((_) async => const ApiSuccessResult(testDelivery));

      final cubit = buildCubit();
      await cubit.loadDelivery(101);

      final updatedDelivery = testDelivery.copyWith(
        status: DeliveryStatus.delivered,
        syncStatus: SyncStatus.synced,
        recipientName: 'Ahmed Rajeh',
      );

      watchStreamController.add([updatedDelivery]);
      await pumpEventQueue();

      expect(cubit.state.delivery?.status, DeliveryStatus.delivered);
      expect(cubit.state.delivery?.recipientName, 'Ahmed Rajeh');

      await cubit.close();
    });
  });
}
