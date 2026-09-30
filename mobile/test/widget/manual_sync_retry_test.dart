import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/repositories/delivery_repo_impl.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/get_deliveries_use_case.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/deliveries/deliveries_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/pages/deliveries_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../unit/sync_retry_fixture.dart';
import '../unit/sync_test_fixtures.dart';

void main() {
  testWidgets(
    'tapping failed sync restarts an exhausted action with its original UUID',
    (tester) async {
      final fixture = RetryFixture();
      final delivery = fixture.delivery.copyWith(
        syncStatus: SyncStatus.failed,
        clientActionId: 'stable-id',
      );
      fixture.queue = [
        fixture.action.copyWith(status: SyncStatus.failed, retryCount: 4),
      ];
      fixture.response = ApiSuccessResult(syncSuccess(7));
      when(
        () => fixture.local.getDeliveries(),
      ).thenAnswer((_) async => [delivery]);
      when(
        () => fixture.local.watchDeliveries(),
      ).thenAnswer((_) => Stream.value([delivery]));
      when(
        () => fixture.remote.getDeliveries(),
      ).thenAnswer((_) async => const ApiErrorResult('offline'));
      final repository = DeliveryRepositoryImpl(fixture.local, fixture.remote);
      final cubit = DeliveriesCubit(
        GetDeliveriesUseCase(repository),
        repository,
        fixture.connectivity,
        fixture.manager,
      );
      getIt.registerFactory<DeliveriesCubit>(() => cubit);
      addTearDown(() async {
        fixture.manager.dispose();
        await getIt.unregister<DeliveriesCubit>();
      });
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DeliveriesListPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('Failed to sync'), findsOneWidget);
      await tester.tap(find.text('Failed to sync'));
      await tester.pump();
      expect(fixture.sentIds, ['stable-id']);
      expect(fixture.queue, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
