import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/helpers/app_snackbar_card.dart';
import 'package:delivery_tracker/core/helpers/phone_launcher_utils.dart';
import 'package:delivery_tracker/core/helpers/snackbar_animated_icon.dart';
import 'package:delivery_tracker/core/helpers/snackbar_utils.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SnackBarUtils and AppSnackbarCard', () {
    testWidgets('shows success snackbar with animated card', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => SnackBarUtils.showSuccess(context, 'Delivery synced'),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppSnackbarCard), findsOneWidget);
      expect(find.text('Delivery synced'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('shows error snackbar with animated card', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => SnackBarUtils.showError(context, 'Sync failed'),
              child: const Text('Show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AppSnackbarCard), findsOneWidget);
      expect(find.text('Sync failed'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows warning and info snackbars', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => SnackBarUtils.showWarning(context, 'Offline mode'),
                  child: const Text('Warning'),
                ),
                ElevatedButton(
                  onPressed: () => SnackBarUtils.showInfo(context, 'Notice'),
                  child: const Text('Info'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Warning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Offline mode'), findsOneWidget);
      expect(find.text('Attention'), findsOneWidget);

      await tester.tap(find.text('Info'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Notice'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);
    });
  });

  group('PhoneLauncherUtils', () {
    testWidgets('handles empty phone gracefully', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PhoneLauncherUtils.makePhoneCall(
                context: context,
                phoneNumber: '---',
              ),
              child: const Text('Call'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Call'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Invalid phone number'), findsOneWidget);
    });
  });
}
