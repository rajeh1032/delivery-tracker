import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_state.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/locale_state.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/features/delivery/presentation/pages/home_shell_page.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}
class MockLocaleCubit extends Mock implements LocaleCubit {}

void main() {
  late MockConnectivityCubit mockConnectivityCubit;
  late MockLocaleCubit mockLocaleCubit;

  setUp(() {
    mockConnectivityCubit = MockConnectivityCubit();
    mockLocaleCubit = MockLocaleCubit();

    when(() => mockConnectivityCubit.state)
        .thenReturn(const ConnectivityState(isOnline: true));
    when(() => mockConnectivityCubit.stream)
        .thenAnswer((_) => const Stream<ConnectivityState>.empty());

    when(() => mockLocaleCubit.state)
        .thenReturn(const LocaleState(Locale('en')));
    when(() => mockLocaleCubit.stream)
        .thenAnswer((_) => const Stream<LocaleState>.empty());
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
    await tester.tap(find.text('Sync Queue'));
    await tester.pumpAndSettle();

    // Tap Settings destination
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Delivery Tracker v1.0.0'), findsOneWidget);
  });
}
