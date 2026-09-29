import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/deliveries_list/deliveries_list_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/deliveries_list/deliveries_list_state.dart';
import 'package:delivery_tracker/main.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}
class MockDeliveriesListCubit extends Mock implements DeliveriesListCubit {}

void main() {
  late MockConnectivityService mockConnectivityService;
  late MockDeliveriesListCubit mockDeliveriesListCubit;
  late ConnectivityCubit connectivityCubit;
  late LocaleCubit localeCubit;

  setUp(() {
    mockConnectivityService = MockConnectivityService();
    mockDeliveriesListCubit = MockDeliveriesListCubit();

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

    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
    getIt.registerFactory<DeliveriesListCubit>(() => mockDeliveriesListCubit);

    connectivityCubit = ConnectivityCubit(mockConnectivityService);
    localeCubit = LocaleCubit();
  });

  tearDown(() {
    connectivityCubit.close();
    localeCubit.close();
    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
  });

  testWidgets('App smoke test renders HomeShellPage and actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DeliveryTrackerApp(
        localeCubit: localeCubit,
        connectivityCubit: connectivityCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);
  });
}
