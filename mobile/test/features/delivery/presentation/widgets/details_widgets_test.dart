import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_actions_bar.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_address_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_amount_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_customer_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_map_header.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_note_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_status_chips.dart';

Widget createLocalizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  const baseDelivery = DeliveryEntity(
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

  group('DetailsMapHeader', () {
    testWidgets('renders order number and handles back tap', (tester) async {
      bool backTapped = false;
      await tester.pumpWidget(
        createLocalizedApp(
          DetailsMapHeader(
            orderNumber: 'ORD-999',
            onBack: () => backTapped = true,
          ),
        ),
      );

      expect(find.text('ORD-999'), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      expect(backTapped, isTrue);
    });
  });

  group('DetailsStatusChips', () {
    testWidgets('renders delivery and sync badges', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const DetailsStatusChips(
            deliveryStatus: DeliveryStatus.pending,
            syncStatus: SyncStatus.synced,
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Synced'), findsOneWidget);
    });
  });

  group('DetailsCustomerCard', () {
    testWidgets('renders customer name, phone, and initial', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const DetailsCustomerCard(
            customerName: 'Fatima Zahra',
            phone: '+965 9876 5432',
          ),
        ),
      );

      expect(find.text('Fatima Zahra'), findsOneWidget);
      expect(find.text('+965 9876 5432'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });
  });

  group('DetailsAddressCard', () {
    testWidgets('renders address and letter badge', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const DetailsAddressCard(
            address: 'Kuwait City, Block 1',
          ),
        ),
      );

      expect(find.text('Kuwait City, Block 1'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    });
  });

  group('DetailsAmountCard', () {
    testWidgets('renders formatted amount and payment badge', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const DetailsAmountCard(
            amountDue: 24.500,
            paymentMethod: 'cash',
          ),
        ),
      );

      expect(find.text('24.500 KWD'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });
  });

  group('DetailsNoteCard', () {
    testWidgets('returns empty when no resolution fields', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const DetailsNoteCard(),
        ),
      );

      expect(find.byType(DetailsNoteCard), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders recipient and note when present', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const DetailsNoteCard(
            recipientName: 'Ahmed Rajeh',
            note: 'Left at reception',
          ),
        ),
      );

      expect(find.text('Ahmed Rajeh'), findsOneWidget);
      expect(find.text('Left at reception'), findsOneWidget);
    });
  });

  group('DetailsActionsBar', () {
    testWidgets('pending + canAct enables buttons and handles taps', (tester) async {
      bool deliveredTapped = false;
      bool failedTapped = false;

      await tester.pumpWidget(
        createLocalizedApp(
          DetailsActionsBar(
            delivery: baseDelivery,
            onMarkDelivered: () => deliveredTapped = true,
            onMarkFailed: () => failedTapped = true,
          ),
        ),
      );

      expect(find.text('Mark as Delivered'), findsOneWidget);
      expect(find.text('Mark as Failed'), findsOneWidget);

      await tester.tap(find.text('Mark as Delivered'));
      expect(deliveredTapped, isTrue);

      await tester.tap(find.text('Mark as Failed'));
      expect(failedTapped, isTrue);
    });

    testWidgets('pending + isFrozen disables buttons and displays freeze warning', (tester) async {
      final frozenDelivery = baseDelivery.copyWith(
        syncStatus: SyncStatus.waitingToSync,
      );

      bool deliveredTapped = false;

      await tester.pumpWidget(
        createLocalizedApp(
          DetailsActionsBar(
            delivery: frozenDelivery,
            onMarkDelivered: () => deliveredTapped = true,
          ),
        ),
      );

      expect(find.text('Action is currently syncing. Please wait.'), findsOneWidget);

      await tester.tap(find.text('Mark as Delivered'));
      expect(deliveredTapped, isFalse);
    });

    testWidgets('delivered status displays resolution banner', (tester) async {
      final delivered = baseDelivery.copyWith(
        status: DeliveryStatus.delivered,
      );

      await tester.pumpWidget(
        createLocalizedApp(
          DetailsActionsBar(delivery: delivered),
        ),
      );

      expect(
        find.text('This order has been successfully delivered.'),
        findsOneWidget,
      );
    });

    testWidgets('failed status displays failure banner', (tester) async {
      final failed = baseDelivery.copyWith(
        status: DeliveryStatus.failed,
      );

      await tester.pumpWidget(
        createLocalizedApp(
          DetailsActionsBar(delivery: failed),
        ),
      );

      expect(
        find.text('This delivery was marked as failed.'),
        findsOneWidget,
      );
    });
  });
}
