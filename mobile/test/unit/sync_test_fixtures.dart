import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';

DeliveryResponseDto syncDelivery({
  required int id,
  required String status,
  required int version,
}) => DeliveryResponseDto(
  id: id,
  orderNumber: 'ORD-$id',
  customerName: 'Sam',
  phone: '555',
  address: 'Town',
  amountDue: 10,
  status: status,
  version: version,
);

DeliveryActionResponseDto syncSuccess(int id) => DeliveryActionResponseDto(
  message: 'ok',
  delivery: syncDelivery(id: id, status: 'delivered', version: 2),
);

DeliveryResponseDto refreshServer() => const DeliveryResponseDto(
  id: 7,
  orderNumber: 'ORD-7',
  customerName: 'New name',
  phone: '555',
  address: 'Town',
  amountDue: 10,
  status: 'pending',
  version: 3,
);
