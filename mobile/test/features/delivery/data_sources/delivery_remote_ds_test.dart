import 'dart:io';
import 'package:delivery_tracker/core/network/api_services.dart';
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

  group('DeliveryRemoteDsImpl', () {
    test('getDeliveries returns list of deliveries from ApiServices', () async {
      when(() => mockApiServices.getDeliveries())
          .thenAnswer((_) async => [sampleDeliveryDto]);

      final result = await remoteDataSource.getDeliveries();

      expect(result.length, 1);
      expect(result.first.id, 1001);
      verify(() => mockApiServices.getDeliveries()).called(1);
    });

    test('getDeliveryById returns single delivery from ApiServices', () async {
      when(() => mockApiServices.getDeliveryById(1001))
          .thenAnswer((_) async => sampleDeliveryDto);

      final result = await remoteDataSource.getDeliveryById(1001);

      expect(result.id, 1001);
      expect(result.customerName, 'Ahmed Ali');
      verify(() => mockApiServices.getDeliveryById(1001)).called(1);
    });

    test('completeDelivery forwards request and returns response dto',
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

      expect(result.message, 'Delivery completed successfully');
      expect(result.delivery.id, 1001);
      verify(() => mockApiServices.completeDelivery(1001, request)).called(1);
    });

    test('failDelivery forwards request and returns response dto', () async {
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

      expect(result.message, 'Delivery marked as failed');
      expect(result.delivery.id, 1001);
      verify(() => mockApiServices.failDelivery(1001, request)).called(1);
    });

    test('uploadProof forwards file and returns proof response dto', () async {
      final fakePhoto = File('/path/to/fake_photo.jpg');
      const proofResponse = ProofUploadResponseDto(
        message: 'Proof uploaded successfully',
        proofUrl: '/uploads/sample.jpg',
      );

      when(() => mockApiServices.uploadProof(1001, any()))
          .thenAnswer((_) async => proofResponse);

      final result = await remoteDataSource.uploadProof(1001, fakePhoto);

      expect(result.message, 'Proof uploaded successfully');
      expect(result.proofUrl, '/uploads/sample.jpg');
      verify(() => mockApiServices.uploadProof(1001, fakePhoto)).called(1);
    });
  });
}
