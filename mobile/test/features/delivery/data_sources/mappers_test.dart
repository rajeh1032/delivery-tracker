import 'package:delivery_tracker/core/utils/constants.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/mapper/to_dto_mapper.dart';
import 'package:delivery_tracker/features/delivery/data_sources/mapper/to_entity_mapper.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DTO Mappers & JSON Serialization', () {
    test('DeliveryResponseDto.fromJson parses full backend payload', () {
      final json = {
        'id': 1001,
        'order_number': 'ORD-1001',
        'customer_name': 'Ahmed Ali',
        'phone': '55512345',
        'address': 'Salmiya, Block 4',
        'amount_due': 18.75,
        'payment_method': 'cash',
        'status': 'pending',
        'version': 2,
        'recipient_name': 'Ali',
        'failure_reason': null,
        'note': 'Call before arrival',
        'proof_url': 'http://image.jpg',
        'client_action_id': 'action-uuid',
        'completed_at': '2026-09-29T10:00:00.000Z',
        'failed_at': null,
      };

      final dto = DeliveryResponseDto.fromJson(json);

      expect(dto.id, 1001);
      expect(dto.orderNumber, 'ORD-1001');
      expect(dto.customerName, 'Ahmed Ali');
      expect(dto.phone, '55512345');
      expect(dto.address, 'Salmiya, Block 4');
      expect(dto.amountDue, 18.75);
      expect(dto.paymentMethod, 'cash');
      expect(dto.status, 'pending');
      expect(dto.version, 2);
      expect(dto.recipientName, 'Ali');
      expect(dto.failureReason, isNull);
      expect(dto.note, 'Call before arrival');
      expect(dto.proofUrl, 'http://image.jpg');
      expect(dto.clientActionId, 'action-uuid');
      expect(dto.completedAt, '2026-09-29T10:00:00.000Z');

      final serialized = dto.toJson();
      expect(serialized['id'], 1001);
      expect(serialized['order_number'], 'ORD-1001');
    });

    test('DeliveryResponseDto handles integer amount_due gracefully', () {
      final json = {
        'id': 1002,
        'order_number': 'ORD-1002',
        'customer_name': 'Fatima',
        'phone': '55567890',
        'address': 'Hawally',
        'amount_due': 25,
        'status': 'pending',
      };

      final dto = DeliveryResponseDto.fromJson(json);
      expect(dto.amountDue, 25.0);
    });

    test('toEntity maps DeliveryResponseDto to DeliveryEntity properly', () {
      const dto = DeliveryResponseDto(
        id: 1003,
        orderNumber: 'ORD-1003',
        customerName: 'Mohammad',
        phone: '55598765',
        address: 'Kuwait City',
        amountDue: 12.0,
        status: 'delivered',
        version: 3,
        recipientName: 'Wife',
        completedAt: '2026-09-29T12:30:00.000Z',
      );

      final entity = dto.toEntity();

      expect(entity.id, 1003);
      expect(entity.orderNumber, 'ORD-1003');
      expect(entity.customerName, 'Mohammad');
      expect(entity.status, DeliveryStatus.delivered);
      expect(entity.syncStatus, SyncStatus.synced);
      expect(entity.paymentMethod, AppConstants.defaultPaymentMethod);
      expect(entity.recipientName, 'Wife');
      expect(entity.version, 3);
      expect(entity.updatedAt, DateTime.parse('2026-09-29T12:30:00.000Z'));
    });

    test('toEntities maps list of DTOs to list of entities', () {
      const list = [
        DeliveryResponseDto(
          id: 1,
          orderNumber: 'ORD-1',
          customerName: 'User 1',
          phone: '111',
          address: 'Addr 1',
          amountDue: 10,
          status: 'pending',
        ),
        DeliveryResponseDto(
          id: 2,
          orderNumber: 'ORD-2',
          customerName: 'User 2',
          phone: '222',
          address: 'Addr 2',
          amountDue: 20,
          status: 'failed',
          failureReason: 'wrong_address',
          failedAt: '2026-09-29T15:00:00.000Z',
        ),
      ];

      final entities = list.toEntities();

      expect(entities.length, 2);
      expect(entities[0].id, 1);
      expect(entities[0].status, DeliveryStatus.pending);
      expect(entities[1].id, 2);
      expect(entities[1].status, DeliveryStatus.failed);
      expect(entities[1].failureReason, FailureReason.wrongAddress);
      expect(entities[1].updatedAt, DateTime.parse('2026-09-29T15:00:00.000Z'));
    });

    test('DeliveryAction toCompleteRequestDto maps payload correctly', () {
      final action = DeliveryAction(
        clientActionId: 'client-uuid-1',
        deliveryId: 1001,
        type: DeliveryActionType.complete,
        payload: {
          'recipient_name': 'Brother',
          'note': 'Left with security',
          'base_version': 2,
        },
        createdAt: DateTime.now(),
      );

      final dto = action.toCompleteRequestDto();

      expect(dto.recipientName, 'Brother');
      expect(dto.note, 'Left with security');
      expect(dto.clientActionId, 'client-uuid-1');
      expect(dto.baseVersion, 2);

      final json = dto.toJson();
      expect(json['recipient_name'], 'Brother');
      expect(json['client_action_id'], 'client-uuid-1');
      expect(json['base_version'], 2);
    });

    test('DeliveryAction toFailRequestDto maps payload correctly', () {
      final action = DeliveryAction(
        clientActionId: 'client-uuid-2',
        deliveryId: 1002,
        type: DeliveryActionType.fail,
        payload: {
          'reason': 'Customer not home',
          'note': 'Called twice, no answer',
          'base_version': 1,
        },
        createdAt: DateTime.now(),
      );

      final dto = action.toFailRequestDto();

      expect(dto.reason, 'Customer not home');
      expect(dto.note, 'Called twice, no answer');
      expect(dto.clientActionId, 'client-uuid-2');
      expect(dto.baseVersion, 1);

      final json = dto.toJson();
      expect(json['reason'], 'Customer not home');
      expect(json['client_action_id'], 'client-uuid-2');
    });

    test('DeliveryActionResponseDto and ProofUploadResponseDto serialization', () {
      final actionJson = {
        'message': 'Delivery completed successfully',
        'delivery': {
          'id': 1001,
          'order_number': 'ORD-1001',
          'customer_name': 'Ahmed Ali',
          'phone': '55512345',
          'address': 'Salmiya',
          'amount_due': 18.75,
          'status': 'delivered',
        }
      };

      final actionDto = DeliveryActionResponseDto.fromJson(actionJson);
      expect(actionDto.message, 'Delivery completed successfully');
      expect(actionDto.delivery.id, 1001);
      expect(actionDto.delivery.status, 'delivered');

      final proofJson = {
        'message': 'Proof uploaded successfully',
        'proof_url': '/uploads/photo.jpg',
        'delivery': {
          'id': 1001,
          'order_number': 'ORD-1001',
          'customer_name': 'Ahmed Ali',
          'phone': '55512345',
          'address': 'Salmiya',
          'amount_due': 18.75,
          'status': 'delivered',
          'proof_url': '/uploads/photo.jpg',
        }
      };

      final proofDto = ProofUploadResponseDto.fromJson(proofJson);
      expect(proofDto.message, 'Proof uploaded successfully');
      expect(proofDto.proofUrl, '/uploads/photo.jpg');
      expect(proofDto.delivery?.proofUrl, '/uploads/photo.jpg');
    });
  });
}
