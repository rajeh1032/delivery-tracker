import 'package:equatable/equatable.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';

/// Lifecycle statuses for the delivery details screen.
enum DeliveryDetailsStatus {
  initial,
  loading,
  loaded,
  notFound,
  error,
}

/// State for the delivery details cubit holding entity and screen status.
class DeliveryDetailsState extends Equatable {
  final DeliveryDetailsStatus status;
  final DeliveryEntity? delivery;
  final String? errorMessage;

  const DeliveryDetailsState({
    this.status = DeliveryDetailsStatus.initial,
    this.delivery,
    this.errorMessage,
  });

  bool get isLoading => status == DeliveryDetailsStatus.loading;
  bool get isLoaded => status == DeliveryDetailsStatus.loaded;
  bool get isNotFound => status == DeliveryDetailsStatus.notFound;
  bool get isError => status == DeliveryDetailsStatus.error;

  DeliveryDetailsState copyWith({
    DeliveryDetailsStatus? status,
    DeliveryEntity? delivery,
    String? errorMessage,
  }) {
    return DeliveryDetailsState(
      status: status ?? this.status,
      delivery: delivery ?? this.delivery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, delivery, errorMessage];
}
