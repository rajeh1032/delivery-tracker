import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/deliveries_list/deliveries_list_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/deliveries_list/deliveries_list_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/sync_queue/sync_queue_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/sync_queue/sync_queue_state.dart';
import 'package:delivery_tracker/main.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}
class MockDeliveriesListCubit extends Mock implements DeliveriesListCubit {}
class MockSyncQueueCubit extends Mock implements SyncQueueCubit {}

void main() {
  late MockConnectivityService mockConnectivityService;
  late MockDeliveriesListCubit mockDeliveriesListCubit;
  late MockSyncQueueCubit mockSyncQueueCubit;
  late ConnectivityCubit connectivityCubit;
  late LocaleCubit localeCubit;

  setUp(() {
    mockConnectivityService = MockConnectivityService();
    mockDeliveriesListCubit = MockDeliveriesListCubit();
    mockSyncQueueCubit = MockSyncQueueCubit();

    when(() => mockConnectivityService.checkReachability())
        .thenAnswer((_) async => true);
    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => const Stream<bool>.empty());

    when(() => mockDeliveriesListCubit.state)
        .thenReturn(const DeliveriesListState());
    when(() => mockDeliveriesListCubit.stream)
        .thenAnswer((_) => const Stream<DeliveriesListState>.empty());
    when(() => mockDeliveriesListCubit.loadDeliveries())
        .thenAnswer((_) async {});
    when(() => mockDeliveriesListCubit.close())
        .thenAnswer((_) async {});

    when(() => mockSyncQueueCubit.state)
        .thenReturn(const SyncQueueState());
    when(() => mockSyncQueueCubit.stream)
        .thenAnswer((_) => const Stream<SyncQueueState>.empty());
    when(() => mockSyncQueueCubit.close())
        .thenAnswer((_) async {});

    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
    getIt.registerFactory<DeliveriesListCubit>(() => mockDeliveriesListCubit);

    if (getIt.isRegistered<SyncQueueCubit>()) {
      getIt.unregister<SyncQueueCubit>();
    }
    getIt.registerFactory<SyncQueueCubit>(() => mockSyncQueueCubit);

    connectivityCubit = ConnectivityCubit(mockConnectivityService);
    localeCubit = LocaleCubit();
  });

  tearDown(() {
    connectivityCubit.close();
    localeCubit.close();
    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
    if (getIt.isRegistered<SyncQueueCubit>()) {
      getIt.unregister<SyncQueueCubit>();
    }
  });

  testWidgets('App smoke test renders HomeShellPage and navigation bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DeliveryTrackerApp(
        localeCubit: localeCubit,
        connectivityCubit: connectivityCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery Tracker'), findsOneWidget);
    expect(find.text('Deliveries'), findsWidgets);
    expect(find.text('Sync Queue'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
