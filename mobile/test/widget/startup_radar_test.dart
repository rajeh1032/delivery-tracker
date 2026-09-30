import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/pages/deliveries_list_page.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/list/deliveries_empty_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/radar/deliveries_searching_radar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStartupCubit extends Mock implements DeliveriesCubit {}

void main() {
  late MockStartupCubit cubit;
  setUp(() {
    cubit = MockStartupCubit();
    when(
      () => cubit.state,
    ).thenReturn(const DeliveriesState(status: DeliveriesStatus.empty));
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.loadDeliveries()).thenAnswer((_) async {});
    when(() => cubit.close()).thenAnswer((_) async {});
    getIt.registerFactory<DeliveriesCubit>(() => cubit);
  });
  tearDown(() => getIt.unregister<DeliveriesCubit>());

  Widget app(String language) => MaterialApp(
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: DeliveriesListPage()),
  );

  for (final language in ['ar', 'en']) {
    testWidgets('$language startup radar lasts 800ms with immediate data', (
      tester,
    ) async {
      await tester.pumpWidget(app(language));
      verify(() => cubit.loadDeliveries()).called(1);
      expect(find.byType(DeliveriesSearchingRadar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 799));
      expect(find.byType(DeliveriesSearchingRadar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(DeliveriesSearchingRadar), findsNothing);
      expect(find.byType(DeliveriesEmptyState), findsOneWidget);
      await tester.pumpWidget(app(language == 'ar' ? 'en' : 'ar'));
      await tester.pump();
      expect(find.byType(DeliveriesSearchingRadar), findsNothing);
    });
  }

  testWidgets('leaving during startup cancels the radar timer', (tester) async {
    await tester.pumpWidget(app('ar'));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull);
  });
}
