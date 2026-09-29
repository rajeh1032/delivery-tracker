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
import 'package:delivery_tracker/features/delivery/presentation/pages/home_shell_page.dart';

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}
class MockLocaleCubit extends Mock implements LocaleCubit {}
class MockDeliveriesListCubit extends Mock implements DeliveriesListCubit {}

void main() {
  late MockConnectivityCubit mockConnectivityCubit;
  late MockLocaleCubit mockLocaleCubit;
  late MockDeliveriesListCubit mockDeliveriesListCubit;

  setUp(() {
    mockConnectivityCubit = MockConnectivityCubit();
    mockLocaleCubit = MockLocaleCubit();
    mockDeliveriesListCubit = MockDeliveriesListCubit();

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

    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
    }
    getIt.registerFactory<DeliveriesListCubit>(() => mockDeliveriesListCubit);
  });

  tearDown(() {
    if (getIt.isRegistered<DeliveriesListCubit>()) {
      getIt.unregister<DeliveriesListCubit>();
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

  testWidgets('renders HomeShellPage with actions and handles language toggle',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Delivery Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);

    // Tap language icon
    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    verify(() => mockLocaleCubit.toggleLocale()).called(1);
  });
}
