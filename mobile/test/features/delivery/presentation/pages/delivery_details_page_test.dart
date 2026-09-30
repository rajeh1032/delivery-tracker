import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/delivery_details/delivery_details_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/delivery_details/delivery_details_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/pages/delivery_details_page.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/delivery_details_error_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/delivery_details_not_found_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/delivery_details_skeleton.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_actions_bar.dart';

class MockDeliveryDetailsCubit extends Mock implements DeliveryDetailsCubit {}

void main() {
  late MockDeliveryDetailsCubit mockCubit;
  late StreamController<DeliveryDetailsState> stateController;

  const testDelivery = DeliveryEntity(
    id: 101,
    orderNumber: 'ORD-101',
    customerName: 'Fatima Zahra',
    phone: '+965 9876 5432',
    address: 'Salmiya, Block 4, Street 12, Building 8',
    amountDue: 24.500,
    paymentMethod: 'cash',
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.synced,
  );

  setUp(() {
    mockCubit = MockDeliveryDetailsCubit();
    stateController = StreamController<DeliveryDetailsState>.broadcast();

    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.loadDelivery(any(), preloaded: any(named: 'preloaded')))
        .thenAnswer((_) async {});

    if (getIt.isRegistered<DeliveryDetailsCubit>()) {
      getIt.unregister<DeliveryDetailsCubit>();
    }
    getIt.registerFactory<DeliveryDetailsCubit>(() => mockCubit);
  });

  tearDown(() {
    stateController.close();
    if (getIt.isRegistered<DeliveryDetailsCubit>()) {
      getIt.unregister<DeliveryDetailsCubit>();
    }
  });

  Widget buildTestApp({int deliveryId = 101, DeliveryEntity? preloaded}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: DeliveryDetailsPage(
        deliveryId: deliveryId,
        preloaded: preloaded,
      ),
    );
  }

  group('DeliveryDetailsPage', () {
    testWidgets('renders skeleton when loading with null delivery', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const DeliveryDetailsState(status: DeliveryDetailsStatus.loading),
      );

      await tester.pumpWidget(buildTestApp());
      expect(find.byType(DeliveryDetailsSkeleton), findsOneWidget);
    });

    testWidgets('renders not found state when status is notFound', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const DeliveryDetailsState(status: DeliveryDetailsStatus.notFound),
      );

      await tester.pumpWidget(buildTestApp());
      expect(find.byType(DeliveryDetailsNotFoundState), findsOneWidget);
      expect(find.text('Delivery not found'), findsOneWidget);
    });

    testWidgets('renders error state and retries on press', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const DeliveryDetailsState(
          status: DeliveryDetailsStatus.error,
          errorMessage: 'Server Error',
        ),
      );

      await tester.pumpWidget(buildTestApp());
      expect(find.byType(DeliveryDetailsErrorState), findsOneWidget);
      expect(find.text('Server Error'), findsOneWidget);
    });

    testWidgets('renders full details content when loaded', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const DeliveryDetailsState(
          status: DeliveryDetailsStatus.loaded,
          delivery: testDelivery,
        ),
      );

      await tester.pumpWidget(buildTestApp());

      expect(find.text('ORD-101'), findsNWidgets(2));
      expect(find.text('Fatima Zahra'), findsOneWidget);
      expect(find.text('+965 9876 5432'), findsOneWidget);
      expect(find.text('Salmiya, Block 4, Street 12, Building 8'), findsOneWidget);
      expect(find.text('24.500 KWD'), findsOneWidget);
      expect(find.byType(DetailsActionsBar), findsOneWidget);
    });

    testWidgets('renders freeze warning when delivery is waiting to sync', (tester) async {
      final frozenDelivery = testDelivery.copyWith(
        syncStatus: SyncStatus.waitingToSync,
      );

      when(() => mockCubit.state).thenReturn(
        DeliveryDetailsState(
          status: DeliveryDetailsStatus.loaded,
          delivery: frozenDelivery,
        ),
      );

      await tester.pumpWidget(buildTestApp());
      expect(find.text('Action is currently syncing. Please wait.'), findsOneWidget);
    });
  });
}
