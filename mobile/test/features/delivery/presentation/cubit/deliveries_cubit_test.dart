import 'dart:async';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/get_deliveries_use_case.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_state.dart';

class MockSyncManager extends Mock implements SyncManager {}

class MockGetDeliveriesUseCase extends Mock implements GetDeliveriesUseCase {}

class MockDeliveryRepository extends Mock implements DeliveryRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockGetDeliveriesUseCase mockGetDeliveriesUseCase;
  late MockDeliveryRepository mockDeliveryRepository;
  late MockConnectivityService mockConnectivityService;
  late StreamController<List<DeliveryEntity>> watchStreamController;

  final testDeliveries = [
    const DeliveryEntity(
      id: 1,
      orderNumber: 'ORD-101',
      customerName: 'Ahmed Ali',
      phone: '+965 55512345',
      address: 'Salmiya Block 4',
      amountDue: 18.750,
      paymentMethod: 'cash',
      status: DeliveryStatus.pending,
      syncStatus: SyncStatus.synced,
    ),
    const DeliveryEntity(
      id: 2,
      orderNumber: 'ORD-102',
      customerName: 'Sara Fahad',
      phone: '+965 66612345',
      address: 'Hawally Block 2',
      amountDue: 12.000,
      paymentMethod: 'instapay',
      status: DeliveryStatus.delivered,
      syncStatus: SyncStatus.synced,
    ),
    const DeliveryEntity(
      id: 3,
      orderNumber: 'ORD-103',
      customerName: 'Omar Zaid',
      phone: '+965 99912345',
      address: 'Kuwait City',
      amountDue: 25.500,
      paymentMethod: 'cash',
      status: DeliveryStatus.failed,
      syncStatus: SyncStatus.failed,
    ),
  ];

  setUp(() {
    mockGetDeliveriesUseCase = MockGetDeliveriesUseCase();
    mockDeliveryRepository = MockDeliveryRepository();
    mockConnectivityService = MockConnectivityService();
    watchStreamController = StreamController<List<DeliveryEntity>>.broadcast();

    when(() => mockDeliveryRepository.watchDeliveries())
        .thenAnswer((_) => watchStreamController.stream);
  });

  tearDown(() {
    watchStreamController.close();
  });

  DeliveriesCubit createCubit() {
    return DeliveriesCubit(
      mockGetDeliveriesUseCase,
      mockDeliveryRepository,
      mockConnectivityService,
      MockSyncManager(),
    );
  }

  group('DeliveriesCubit', () {
    test('initial state has empty deliveries and all-filter', () {
      final cubit = createCubit();
      expect(cubit.state.status, DeliveriesStatus.initial);
      expect(cubit.state.deliveries, isEmpty);
      expect(cubit.state.filter, DeliveryStatusFilter.all);
      cubit.close();
    });

    blocTest<DeliveriesCubit, DeliveriesState>(
      'loadDeliveries emits loading and loaded with items on ApiSuccessResult',
      build: () {
        when(() => mockGetDeliveriesUseCase.invoke())
            .thenAnswer((_) async => ApiSuccessResult(testDeliveries));
        return createCubit();
      },
      act: (cubit) => cubit.loadDeliveries(),
      expect: () => [
        const DeliveriesState(status: DeliveriesStatus.loading),
        DeliveriesState(
          status: DeliveriesStatus.loaded,
          deliveries: testDeliveries,
        ),
      ],
    );

    blocTest<DeliveriesCubit, DeliveriesState>(
      'loadDeliveries emits empty state when returned list is empty',
      build: () {
        when(() => mockGetDeliveriesUseCase.invoke())
            .thenAnswer((_) async => const ApiSuccessResult([]));
        return createCubit();
      },
      act: (cubit) => cubit.loadDeliveries(),
      expect: () => [
        const DeliveriesState(status: DeliveriesStatus.loading),
        const DeliveriesState(
          status: DeliveriesStatus.empty,
          deliveries: [],
        ),
      ],
    );

    blocTest<DeliveriesCubit, DeliveriesState>(
      'loadDeliveries emits error when remote fails and cache is empty',
      build: () {
        when(() => mockGetDeliveriesUseCase.invoke()).thenAnswer(
          (_) async => const ApiErrorResult('No internet connection'),
        );
        return createCubit();
      },
      act: (cubit) => cubit.loadDeliveries(),
      expect: () => [
        const DeliveriesState(status: DeliveriesStatus.loading),
        const DeliveriesState(
          status: DeliveriesStatus.error,
          errorMessage: 'No internet connection',
        ),
      ],
    );

    blocTest<DeliveriesCubit, DeliveriesState>(
      'watchDeliveries stream emission automatically updates cubit state',
      build: () => createCubit(),
      act: (cubit) {
        watchStreamController.add(testDeliveries);
      },
      expect: () => [
        DeliveriesState(
          status: DeliveriesStatus.loaded,
          deliveries: testDeliveries,
        ),
      ],
    );

    test('searchChanged and filterChanged correctly compute visibleDeliveries',
        () async {
      final cubit = createCubit();
      watchStreamController.add(testDeliveries);
      await Future.delayed(Duration.zero);

      // Filter: pending
      cubit.filterChanged(DeliveryStatusFilter.pending);
      expect(cubit.state.visibleDeliveries.length, 1);
      expect(cubit.state.visibleDeliveries.first.orderNumber, 'ORD-101');

      // Filter: delivered
      cubit.filterChanged(DeliveryStatusFilter.delivered);
      expect(cubit.state.visibleDeliveries.length, 1);
      expect(cubit.state.visibleDeliveries.first.orderNumber, 'ORD-102');

      // Search: by customer name
      cubit.filterChanged(DeliveryStatusFilter.all);
      cubit.searchChanged('Sara');
      expect(cubit.state.visibleDeliveries.length, 1);
      expect(cubit.state.visibleDeliveries.first.customerName, 'Sara Fahad');

      // Search: by order number
      cubit.searchChanged('103');
      expect(cubit.state.visibleDeliveries.length, 1);
      expect(cubit.state.visibleDeliveries.first.orderNumber, 'ORD-103');

      // Counts getters
      expect(cubit.state.totalCount, 3);
      expect(cubit.state.pendingCount, 1);
      expect(cubit.state.deliveredCount, 1);
      expect(cubit.state.failedCount, 1);

      await cubit.close();
    });
  });
}
