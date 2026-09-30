import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/pages/deliveries_list_page.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/list/deliveries_filter_chips.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/list/deliveries_empty_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/list/deliveries_error_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/list/delivery_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/radar/deliveries_searching_radar.dart';

class MockDeliveriesListCubit extends Mock implements DeliveriesListCubit {}

void main() {
  late MockDeliveriesListCubit mockCubit;
  late StreamController<DeliveriesListState> stateController;

  const testDeliveries = [
    DeliveryEntity(
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
    DeliveryEntity(
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
  ];

  setUp(() {
    mockCubit = MockDeliveriesListCubit();
    stateController = StreamController<DeliveriesListState>.broadcast();

    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.loadDeliveries()).thenAnswer((_) async {});

    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
    getIt.registerFactory<DeliveriesListCubit>(() => mockCubit);
  });

  tearDown(() {
    stateController.close();
    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
  });

  Widget buildTestWidget() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DeliveriesListPage(),
      ),
    );
  }

  testWidgets('renders DeliveriesSearchingRadar when initial loading with empty cache',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const DeliveriesListState(
        status: DeliveriesListStatus.loading,
        deliveries: [],
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    expect(find.byType(DeliveriesSearchingRadar), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(DeliveriesSearchingRadar), findsOneWidget);
  });

  testWidgets('renders cards, search bar, and filter chips when loaded',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const DeliveriesListState(
        status: DeliveriesListStatus.loaded,
        deliveries: testDeliveries,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DeliveryCard), findsNWidgets(2));
    expect(find.text('Ahmed Ali'), findsOneWidget);
    expect(find.text('Sara Fahad'), findsOneWidget);
    expect(find.textContaining('All'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DeliveriesFilterChips),
        matching: find.textContaining('Pending'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(DeliveriesFilterChips),
        matching: find.textContaining('Delivered'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('typing into search bar invokes searchChanged on cubit',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const DeliveriesListState(
        status: DeliveriesListStatus.loaded,
        deliveries: testDeliveries,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Ahmed');
    verify(() => mockCubit.searchChanged('Ahmed')).called(1);
  });

  testWidgets('tapping a filter chip invokes filterChanged on cubit',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const DeliveriesListState(
        status: DeliveriesListStatus.loaded,
        deliveries: testDeliveries,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final pendingChip = find.descendant(
      of: find.byType(DeliveriesFilterChips),
      matching: find.textContaining('Pending'),
    );
    await tester.tap(pendingChip);
    verify(() => mockCubit.filterChanged(DeliveryStatusFilter.pending)).called(1);
  });

  testWidgets('renders DeliveriesErrorState and retries when error occurs',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const DeliveriesListState(
        status: DeliveriesListStatus.error,
        deliveries: [],
        errorMessage: 'Connection lost',
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DeliveriesErrorState), findsOneWidget);
    expect(find.text('Connection lost'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => mockCubit.loadDeliveries()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('renders DeliveriesEmptyState when list is empty',
      (tester) async {
    when(() => mockCubit.state).thenReturn(
      const DeliveriesListState(
        status: DeliveriesListStatus.empty,
        deliveries: [],
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(DeliveriesEmptyState), findsOneWidget);
    expect(find.text('No Deliveries Assigned'), findsOneWidget);
  });
}
