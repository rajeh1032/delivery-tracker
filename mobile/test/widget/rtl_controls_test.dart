import 'package:delivery_tracker/core/components/app_back_button.dart';
import 'package:delivery_tracker/core/components/pill_button.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/badges/delivery_status_badge.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_actions_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget localized(Widget child, String language) => MaterialApp(
  locale: Locale(language),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('back icon mirrors once when locale changes', (tester) async {
    for (final language in ['en', 'ar', 'en']) {
      await tester.pumpWidget(localized(const AppBackButton(), language));
      await tester.pumpAndSettle();
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, Icons.arrow_back_ios_new);
      expect(icon.icon!.matchTextDirection, isTrue);
      expect(
        Directionality.of(tester.element(find.byType(Icon))),
        language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
    }
  });

  for (final language in ['en', 'ar']) {
    testWidgets('$language button and badge icons follow their labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        localized(
          Column(
            children: [
              PillButton(
                text: 'Action',
                icon: const Icon(Icons.check),
                onPressed: () {},
              ),
              const DeliveryStatusBadge(status: DeliveryStatus.pending),
            ],
          ),
          language,
        ),
      );
      await tester.pumpAndSettle();
      final buttonText = tester.getCenter(find.text('Action')).dx;
      final buttonIcon = tester.getCenter(find.byIcon(Icons.check)).dx;
      final badge = find.byType(DeliveryStatusBadge);
      final badgeText = tester
          .getCenter(find.descendant(of: badge, matching: find.byType(Text)))
          .dx;
      final badgeIcon = tester
          .getCenter(find.byIcon(Icons.schedule_rounded))
          .dx;
      expect(
        buttonIcon,
        language == 'ar' ? lessThan(buttonText) : greaterThan(buttonText),
      );
      expect(
        badgeIcon,
        language == 'ar' ? lessThan(badgeText) : greaterThan(badgeText),
      );
    });

    testWidgets('$language primary action is at the reading-order end', (
      tester,
    ) async {
      const delivery = DeliveryEntity(
        id: 1,
        orderNumber: 'ORD-1',
        customerName: 'Sam',
        phone: '+96555512345',
        address: 'Town',
        amountDue: 18.75,
      );
      var delivered = false;
      await tester.pumpWidget(
        localized(
          DetailsActionsBar(
            delivery: delivery,
            onMarkDelivered: () => delivered = true,
            onMarkFailed: () {},
          ),
          language,
        ),
      );
      await tester.pumpAndSettle();
      final tr = AppLocalizations.of(
        tester.element(find.byType(DetailsActionsBar)),
      );
      final primary = tester.getCenter(find.text(tr.markDelivered)).dx;
      final secondary = tester.getCenter(find.text(tr.markFailed)).dx;
      expect(
        primary,
        language == 'ar' ? lessThan(secondary) : greaterThan(secondary),
      );
      await tester.tap(find.text(tr.markDelivered));
      expect(delivered, isTrue);
    });
  }
}
