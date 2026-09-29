import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryTrackerApp());
    expect(find.text('Delivery Tracker Ready'), findsOneWidget);
  });
}
