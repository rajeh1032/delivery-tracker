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
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/sync_queue/sync_queue_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/sync_queue/sync_queue_state.dart';
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
    when(() => mockLocaleCubit.toggleLocale())
        .thenAnswer((_) async {});

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

  testWidgets('renders HomeShellPage with actions and opens sync queue modal',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Delivery Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);

    // Tap Sync Queue icon to open modal bottom sheet
    await tester.tap(find.byIcon(Icons.sync_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Sync Queue'), findsOneWidget);

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Tap language icon
    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    verify(() => mockLocaleCubit.toggleLocale()).called(1);
  });
}
