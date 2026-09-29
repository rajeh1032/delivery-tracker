import 'dart:async';
import 'package:dio/dio.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetConnection extends Mock implements InternetConnection {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockInternetConnection mockInternetConnection;
  late MockDio mockDio;
  late ConnectivityService connectivityService;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  setUp(() {
    mockInternetConnection = MockInternetConnection();
    mockDio = MockDio();
    connectivityService = ConnectivityService(mockInternetConnection, mockDio);
  });

  group('ConnectivityService', () {
    final expectedProbeUrl =
        '${NetworkConstants.baseUrl}${NetworkConstants.deliveries}';

    test('checkInternet returns false when physical connection is absent',
        () async {
      when(() => mockInternetConnection.hasInternetAccess)
          .thenAnswer((_) async => false);

      final result = await connectivityService.checkInternet();

      expect(result, isFalse);
      verifyNever(() => mockDio.get(any(), options: any(named: 'options')));
    });

    test(
        'checkInternet returns true when physical connection exists and server responds',
        () async {
      when(() => mockInternetConnection.hasInternetAccess)
          .thenAnswer((_) async => true);
      when(() => mockDio.get(
            expectedProbeUrl,
            options: any(named: 'options'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: expectedProbeUrl),
          statusCode: 200,
        ),
      );

      final result = await connectivityService.checkInternet();

      expect(result, isTrue);
      expect(await connectivityService.isConnected, isTrue);
      verify(() => mockDio.get(
            expectedProbeUrl,
            options: any(named: 'options'),
          )).called(2);
    });

    test('checkInternet returns false when probe throws DioException / timeout',
        () async {
      when(() => mockInternetConnection.hasInternetAccess)
          .thenAnswer((_) async => true);
      when(() => mockDio.get(
            expectedProbeUrl,
            options: any(named: 'options'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: expectedProbeUrl),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await connectivityService.checkInternet();

      expect(result, isFalse);
    });

    test('checkReachability handles probe with correct timeout options',
        () async {
      when(() => mockDio.get(
            expectedProbeUrl,
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        final options = invocation.namedArguments[const Symbol('options')] as Options?;
        expect(options?.sendTimeout, NetworkConstants.reachabilityTimeout);
        expect(options?.receiveTimeout, NetworkConstants.reachabilityTimeout);
        return Response(
          requestOptions: RequestOptions(path: expectedProbeUrl),
          statusCode: 200,
        );
      });

      final reachable = await connectivityService.checkReachability();
      expect(reachable, isTrue);
    });

    test('onConnectivityChanged stream emits boolean status based on reachability',
        () async {
      final statusController = StreamController<InternetStatus>();
      when(() => mockInternetConnection.onStatusChange)
          .thenAnswer((_) => statusController.stream);

      when(() => mockDio.get(
            expectedProbeUrl,
            options: any(named: 'options'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: expectedProbeUrl),
          statusCode: 200,
        ),
      );

      final emissions = <bool>[];
      final subscription =
          connectivityService.onConnectivityChanged.listen(emissions.add);

      statusController.add(InternetStatus.connected);
      await pumpEventQueue();

      statusController.add(InternetStatus.disconnected);
      await pumpEventQueue();

      expect(emissions, [true, false]);

      await subscription.cancel();
      await statusController.close();
    });
  });
}
