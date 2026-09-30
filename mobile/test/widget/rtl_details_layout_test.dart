import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_amount_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_map_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets('$language details header and amount fit larger text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const Scaffold(
            body: Column(
              children: [
                DetailsMapHeader(orderNumber: 'ORD-1002'),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: DetailsAmountCard(
                    amountDue: 1234.5,
                    paymentMethod: 'cash',
                    orderNumber: 'ORD-1002',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final backX = tester.getCenter(find.byType(IconButton)).dx;
      expect(backX, language == 'ar' ? greaterThan(160) : lessThan(160));
      for (final element in tester.widgetList<Text>(find.text('ORD-1002'))) {
        expect(element.textDirection, TextDirection.ltr);
      }
      expect(
        tester.widget<Text>(find.text('1,234.500 KWD')).textDirection,
        TextDirection.ltr,
      );
    });
  }
}
