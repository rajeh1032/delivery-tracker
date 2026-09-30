import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/radar/deliveries_searching_radar.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/radar/radar_sweep_painter.dart';

void main() {
  testWidgets('DeliveriesSearchingRadar renders custom painter and search text',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DeliveriesSearchingRadar(),
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    expect(find.byType(DeliveriesSearchingRadar), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('Searching for nearby deliveries...'), findsOneWidget);

    // Verify painter renders
    final customPaintFinder = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is RadarSweepPainter,
    );
    expect(customPaintFinder, findsOneWidget);

    // Pump animation frame
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(DeliveriesSearchingRadar), findsOneWidget);
  });
}
