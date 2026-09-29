import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/sync_queue/sync_queue_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_action_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_queue_empty_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_queue_retry_all_button.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/sync_queue/sync_queue_tabs.dart';

Widget createLocalizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('SyncQueueTabs', () {
    testWidgets('renders counts and notifies on selection', (tester) async {
      SyncQueueTab? selected;
      await tester.pumpWidget(
        createLocalizedApp(
          SyncQueueTabs(
            currentTab: SyncQueueTab.pending,
            pendingCount: 3,
            failedCount: 1,
            onTabSelected: (tab) => selected = tab,
          ),
        ),
      );

      expect(find.text('Pending (3)'), findsOneWidget);
      expect(find.text('Failed (1)'), findsOneWidget);

      await tester.tap(find.text('Failed (1)'));
      await tester.pumpAndSettle();

      expect(selected, SyncQueueTab.failed);
    });
  });

  group('SyncActionCard', () {
    testWidgets('renders complete delivery action details', (tester) async {
      final action = DeliveryAction(
        clientActionId: 'act-1',
        deliveryId: 101,
        type: DeliveryActionType.complete,
        payload: const {
          'recipient_name': 'Hassan Ali',
          'note': 'Left with guard',
        },
        status: SyncStatus.waitingToSync,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        createLocalizedApp(
          SyncActionCard(action: action),
        ),
      );

      expect(find.text('Delivery Completion · Order #101'), findsOneWidget);
      expect(find.text('Delivered by: Hassan Ali'), findsOneWidget);
      expect(find.text('Left with guard'), findsOneWidget);
    });

    testWidgets('renders failed action with error, retries, and calls onRetry',
        (tester) async {
      bool retryTapped = false;
      final action = DeliveryAction(
        clientActionId: 'act-2',
        deliveryId: 102,
        type: DeliveryActionType.fail,
        payload: const {'reason': 'Wrong address'},
        status: SyncStatus.failed,
        lastError: 'Server Timeout 504',
        retryCount: 2,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        createLocalizedApp(
          SyncActionCard(
            action: action,
            onRetry: () => retryTapped = true,
          ),
        ),
      );

      expect(find.text('Delivery Failure · Order #102'), findsOneWidget);
      expect(find.text('Failure Reason: Wrong address'), findsOneWidget);
      expect(find.text('Server Timeout 504'), findsOneWidget);
      expect(find.text('Retries: 2'), findsOneWidget);

      await tester.tap(find.text('Failed to sync'));
      expect(retryTapped, isTrue);
    });
  });

  group('SyncQueueEmptyState', () {
    testWidgets('renders pending and failed empty messages', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const SyncQueueEmptyState(tab: SyncQueueTab.pending),
        ),
      );
      expect(find.text('No pending sync actions 🎉'), findsOneWidget);

      await tester.pumpWidget(
        createLocalizedApp(
          const SyncQueueEmptyState(tab: SyncQueueTab.failed),
        ),
      );
      expect(find.text('No failed sync actions'), findsOneWidget);
    });
  });

  group('SyncQueueRetryAllButton', () {
    testWidgets('renders retry button and handles tap', (tester) async {
      bool retryAllTapped = false;
      await tester.pumpWidget(
        createLocalizedApp(
          SyncQueueRetryAllButton(
            isLoading: false,
            onRetryAll: () => retryAllTapped = true,
          ),
        ),
      );

      expect(find.text('Retry All'), findsOneWidget);
      await tester.tap(find.text('Retry All'));
      expect(retryAllTapped, isTrue);
    });
  });
}
