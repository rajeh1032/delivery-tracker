import 'dart:io';
import 'package:dio/dio.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/api_services.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/request/fail_delivery_request_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiServices extends Mock implements ApiServices {}

class FakeCompleteDeliveryRequestDto extends Fake
    implements CompleteDeliveryRequestDto {}

class FakeFailDeliveryRequestDto extends Fake
    implements FailDeliveryRequestDto {}

class FakeFile extends Fake implements File {}

void main() {
  late MockApiServices mockApiServices;
  late DeliveryRemoteDs remoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeCompleteDeliveryRequestDto());
    registerFallbackValue(FakeFailDeliveryRequestDto());
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockApiServices = MockApiServices();
    remoteDataSource = DeliveryRemoteDsImpl(mockApiServices);
  });

  const sampleDeliveryDto = DeliveryResponseDto(
    id: 1001,
    orderNumber: 'ORD-1001',
    customerName: 'Ahmed Ali',
    phone: '55512345',
    address: 'Salmiya',
    amountDue: 18.75,
    status: 'pending',
  );

  group('DeliveryRemoteDsImpl wrapped in safeApiCall', () {
    test('getDeliveries returns ApiSuccessResult with list of deliveries',
        () async {
      when(() => mockApiServices.getDeliveries())
          .thenAnswer((_) async => [sampleDeliveryDto]);

      final result = await remoteDataSource.getDeliveries();

      expect(result.isSuccess, isTrue);
      expect(result, isA<ApiSuccessResult<List<DeliveryResponseDto>>>());
      final data = (result as ApiSuccessResult<List<DeliveryResponseDto>>).data;
      expect(data.length, 1);
      expect(data.first.id, 1001);
      verify(() => mockApiServices.getDeliveries()).called(1);
    });

    test('getDeliveries returns ApiErrorResult when network call throws DioException',
        () async {
      when(() => mockApiServices.getDeliveries()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/deliveries'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await remoteDataSource.getDeliveries();

      expect(result.isFailure, isTrue);
      expect(result, isA<ApiErrorResult<List<DeliveryResponseDto>>>());
      final error = result as ApiErrorResult<List<DeliveryResponseDto>>;
      expect(error.failure, isA<TransientFailure>());
      expect(error.failure.isRetryable, isTrue);
    });

    test('getDeliveryById returns ApiSuccessResult with delivery', () async {
      when(() => mockApiServices.getDeliveryById(1001))
          .thenAnswer((_) async => sampleDeliveryDto);

      final result = await remoteDataSource.getDeliveryById(1001);

      expect(result.isSuccess, isTrue);
      final data = (result as ApiSuccessResult<DeliveryResponseDto>).data;
      expect(data.id, 1001);
      expect(data.customerName, 'Ahmed Ali');
      verify(() => mockApiServices.getDeliveryById(1001)).called(1);
    });

    test('completeDelivery forwards request and returns ApiSuccessResult',
        () async {
      const request = CompleteDeliveryRequestDto(
        recipientName: 'Omar',
        clientActionId: 'action-123',
      );
      const actionResponse = DeliveryActionResponseDto(
        message: 'Delivery completed successfully',
        delivery: sampleDeliveryDto,
      );

      when(() => mockApiServices.completeDelivery(1001, any()))
          .thenAnswer((_) async => actionResponse);

      final result = await remoteDataSource.completeDelivery(1001, request);

      expect(result.isSuccess, isTrue);
      final data =
          (result as ApiSuccessResult<DeliveryActionResponseDto>).data;
      expect(data.message, 'Delivery completed successfully');
      expect(data.delivery.id, 1001);
      verify(() => mockApiServices.completeDelivery(1001, request)).called(1);
    });

    test('failDelivery forwards request and returns ApiSuccessResult',
        () async {
      const request = FailDeliveryRequestDto(
        reason: 'Customer absent',
        clientActionId: 'action-456',
      );
      const actionResponse = DeliveryActionResponseDto(
        message: 'Delivery marked as failed',
        delivery: sampleDeliveryDto,
      );

      when(() => mockApiServices.failDelivery(1001, any()))
          .thenAnswer((_) async => actionResponse);

      final result = await remoteDataSource.failDelivery(1001, request);

      expect(result.isSuccess, isTrue);
      final data =
          (result as ApiSuccessResult<DeliveryActionResponseDto>).data;
      expect(data.message, 'Delivery marked as failed');
      expect(data.delivery.id, 1001);
      verify(() => mockApiServices.failDelivery(1001, request)).called(1);
    });

    test('uploadProof forwards file and returns ApiSuccessResult', () async {
      final fakePhoto = File('/path/to/fake_photo.jpg');
      const proofResponse = ProofUploadResponseDto(
        message: 'Proof uploaded successfully',
        proofUrl: '/uploads/sample.jpg',
      );

      when(() => mockApiServices.uploadProof(1001, any()))
          .thenAnswer((_) async => proofResponse);

      final result = await remoteDataSource.uploadProof(1001, fakePhoto);

      expect(result.isSuccess, isTrue);
      final data = (result as ApiSuccessResult<ProofUploadResponseDto>).data;
      expect(data.message, 'Proof uploaded successfully');
      expect(data.proofUrl, '/uploads/sample.jpg');
      verify(() => mockApiServices.uploadProof(1001, fakePhoto)).called(1);
    });

    test('uploadProof returns ApiErrorResult when upload fails with bad response',
        () async {
      final fakePhoto = File('/path/to/fake_photo.jpg');

      when(() => mockApiServices.uploadProof(1001, any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/deliveries/1001/proof'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/deliveries/1001/proof'),
            statusCode: 400,
            data: {'message': 'photo is required'},
          ),
        ),
      );

      final result = await remoteDataSource.uploadProof(1001, fakePhoto);

      expect(result.isFailure, isTrue);
      final error = result as ApiErrorResult<ProofUploadResponseDto>;
      expect(error.message, 'photo is required');
      expect(error.failure, isA<PermanentFailure>());
      expect(error.failure.isRetryable, isFalse);
    });
  });
}
