import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockConnectivityService mockService;
  late StreamController<bool> connectivityController;

  setUp(() {
    mockService = MockConnectivityService();
    connectivityController = StreamController<bool>.broadcast();
    when(() => mockService.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
  });

  tearDown(() {
    connectivityController.close();
  });

  test('initial state queries reachability', () async {
    when(() => mockService.checkReachability()).thenAnswer((_) async => true);
    final cubit = ConnectivityCubit(mockService);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isOnline, isTrue);
    await cubit.close();
  });

  test('emits offline when connectivity changes to false', () async {
    when(() => mockService.checkReachability()).thenAnswer((_) async => true);
    final cubit = ConnectivityCubit(mockService);
    await Future<void>.delayed(Duration.zero);

    connectivityController.add(false);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isOnline, isFalse);
    expect(cubit.state.justCameOnline, isFalse);
    await cubit.close();
  });

  test('emits justCameOnline true when recovering from offline to online', () async {
    when(() => mockService.checkReachability()).thenAnswer((_) async => false);
    final cubit = ConnectivityCubit(mockService);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isOnline, isFalse);

    connectivityController.add(true);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isOnline, isTrue);
    expect(cubit.state.justCameOnline, isTrue);
    await cubit.close();
  });
}
