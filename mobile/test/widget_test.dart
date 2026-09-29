import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/main.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockConnectivityService mockConnectivityService;
  late ConnectivityCubit connectivityCubit;
  late LocaleCubit localeCubit;

  setUp(() {
    mockConnectivityService = MockConnectivityService();
    when(() => mockConnectivityService.checkReachability())
        .thenAnswer((_) async => true);
    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => const Stream<bool>.empty());

    connectivityCubit = ConnectivityCubit(mockConnectivityService);
    localeCubit = LocaleCubit();
  });

  tearDown(() {
    connectivityCubit.close();
    localeCubit.close();
  });

  testWidgets('App smoke test renders HomeShellPage and navigation bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      DeliveryTrackerApp(
        localeCubit: localeCubit,
        connectivityCubit: connectivityCubit,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery Tracker'), findsOneWidget);
    expect(find.text('Deliveries'), findsWidgets);
    expect(find.text('Sync Queue'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
