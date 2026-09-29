import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_state.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/locale_state.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/deliveries_list/deliveries_list_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/deliveries_list/deliveries_list_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/sync_queue/sync_queue_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/sync_queue/sync_queue_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/pages/home_shell_page.dart';

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}
class MockLocaleCubit extends Mock implements LocaleCubit {}
class MockDeliveriesListCubit extends Mock implements DeliveriesListCubit {}
class MockSyncQueueCubit extends Mock implements SyncQueueCubit {}

void main() {
  late MockConnectivityCubit mockConnectivityCubit;
  late MockLocaleCubit mockLocaleCubit;
  late MockDeliveriesListCubit mockDeliveriesListCubit;
  late MockSyncQueueCubit mockSyncQueueCubit;

  setUp(() {
    mockConnectivityCubit = MockConnectivityCubit();
    mockLocaleCubit = MockLocaleCubit();
    mockDeliveriesListCubit = MockDeliveriesListCubit();
    mockSyncQueueCubit = MockSyncQueueCubit();

    when(() => mockConnectivityCubit.state)
        .thenReturn(const ConnectivityState(isOnline: true));
    when(() => mockConnectivityCubit.stream)
        .thenAnswer((_) => const Stream<ConnectivityState>.empty());

    when(() => mockLocaleCubit.state)
        .thenReturn(const LocaleState(Locale('en')));
    when(() => mockLocaleCubit.stream)
        .thenAnswer((_) => const Stream<LocaleState>.empty());

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
  });

  tearDown(() {
    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
    if (getIt.isRegistered<SyncQueueCubit>()) {
      getIt.unregister<SyncQueueCubit>();
    }
  });

  Widget buildTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityCubit>.value(value: mockConnectivityCubit),
        BlocProvider<LocaleCubit>.value(value: mockLocaleCubit),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeShellPage(),
      ),
    );
  }

  testWidgets('renders HomeShellPage with tabs and switches index on tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Deliveries'), findsWidgets);
    expect(find.text('Sync Queue'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap Sync Queue destination
    await tester.tap(find.byIcon(Icons.sync_outlined));
    await tester.pumpAndSettle();

    // Tap Settings destination
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Delivery Tracker v1.0.0'), findsOneWidget);
  });
}
