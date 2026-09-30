import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/list/delivery_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final language in ['ar', 'en']) {
    testWidgets('$language long card fits narrow screen with larger text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const delivery = DeliveryEntity(
        id: 2,
        orderNumber: 'ORD-1002',
        customerName: 'عبد الرحمن محمد عبد الله',
        phone: '+965 55512345',
        address: 'السالمية، قطعة ٤، شارع سالم المبارك، عمارة ١٢، الدور الثالث',
        amountDue: 18.75,
        status: DeliveryStatus.delivered,
        syncStatus: SyncStatus.waitingToSync,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: DeliveryCard(delivery: delivery),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final phone = tester.widget<Text>(find.text(delivery.phone));
      final order = tester.widget<Text>(find.text(delivery.orderNumber));
      final amount = tester.widget<Text>(find.textContaining('18.750'));
      expect(phone.textDirection, TextDirection.ltr);
      expect(order.textDirection, TextDirection.ltr);
      expect(amount.textDirection, TextDirection.ltr);
    });
  }
  test('Arabic labels describe driver actions naturally', () async {
    final tr = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(tr.markDelivered, 'تم التسليم');
    expect(tr.markFailed, 'تعذّر التسليم');
    expect(tr.syncStatusSynced, 'تم حفظ التحديث');
    expect(tr.paymentCash, 'نقدًا');
  });
}
