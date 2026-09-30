import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/list/delivery_card.dart';

void main() {
  const testDelivery = DeliveryEntity(
    id: 42,
    orderNumber: 'ORD-9999',
    customerName: 'Khaled Al-Sabah',
    phone: '+965 98765432',
    address: 'Salmiya, Salem Al Mubarak St',
    amountDue: 24.500,
    paymentMethod: 'cash',
    status: DeliveryStatus.pending,
    syncStatus: SyncStatus.synced,
  );

  Widget buildTestWidget({VoidCallback? onTap}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DeliveryCard(
          delivery: testDelivery,
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('DeliveryCard renders customer info, address, fare, and badges',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Khaled Al-Sabah'), findsOneWidget);
    expect(find.text('ORD-9999'), findsOneWidget);
    expect(find.text('+965 98765432'), findsOneWidget);
    expect(find.text('Salmiya, Salem Al Mubarak St'), findsOneWidget);
    expect(find.textContaining('24.500'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
  });

  testWidgets('DeliveryCard invokes onTap callback when pressed',
      (tester) async {
    var wasTapped = false;
    await tester.pumpWidget(buildTestWidget(onTap: () => wasTapped = true));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DeliveryCard));
    expect(wasTapped, isTrue);
  });
}
