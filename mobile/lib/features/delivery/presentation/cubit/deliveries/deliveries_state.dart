import 'package:equatable/equatable.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';

/// Screen-level UI states for the deliveries list.
enum DeliveriesStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Backwards compatibility alias for DeliveriesListStatus
typedef DeliveriesListStatus = DeliveriesStatus;

/// Filter options for segmenting deliveries by status.
enum DeliveryStatusFilter {
  all,
  pending,
  delivered,
  failed,
}

/// Immutable state containing deliveries, active filters, search query, and computed visible list.
class DeliveriesState extends Equatable {
  final DeliveriesStatus status;
  final List<DeliveryEntity> deliveries;
  final String searchQuery;
  final DeliveryStatusFilter filter;
  final String? errorMessage;

  const DeliveriesState({
    this.status = DeliveriesStatus.initial,
    this.deliveries = const [],
    this.searchQuery = '',
    this.filter = DeliveryStatusFilter.all,
    this.errorMessage,
  });

  /// Deliveries filtered by selected status chip and search query.
  List<DeliveryEntity> get visibleDeliveries {
    return deliveries.where((d) {
      final matchesFilter = switch (filter) {
        DeliveryStatusFilter.all => true,
        DeliveryStatusFilter.pending => d.status == DeliveryStatus.pending,
        DeliveryStatusFilter.delivered => d.status == DeliveryStatus.delivered,
        DeliveryStatusFilter.failed => d.status == DeliveryStatus.failed,
      };
      if (!matchesFilter) return false;

      final query = searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;

      final matchesOrder = d.orderNumber.toLowerCase().contains(query);
      final matchesCustomer = d.customerName.toLowerCase().contains(query);
      final matchesAddress = d.address.toLowerCase().contains(query);
      return matchesOrder || matchesCustomer || matchesAddress;
    }).toList(growable: false);
  }

  int get totalCount => deliveries.length;
  int get pendingCount =>
      deliveries.where((d) => d.status == DeliveryStatus.pending).length;
  int get deliveredCount =>
      deliveries.where((d) => d.status == DeliveryStatus.delivered).length;
  int get failedCount =>
      deliveries.where((d) => d.status == DeliveryStatus.failed).length;

  bool get isLoading => status == DeliveriesStatus.loading;
  bool get isInitial => status == DeliveriesStatus.initial;
  bool get isLoaded => status == DeliveriesStatus.loaded;
  bool get isEmpty => status == DeliveriesStatus.empty;
  bool get isError => status == DeliveriesStatus.error;

  DeliveriesState copyWith({
    DeliveriesStatus? status,
    List<DeliveryEntity>? deliveries,
    String? searchQuery,
    DeliveryStatusFilter? filter,
    String? errorMessage,
  }) {
    return DeliveriesState(
      status: status ?? this.status,
      deliveries: deliveries ?? this.deliveries,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        deliveries,
        searchQuery,
        filter,
        errorMessage,
      ];
}

/// Backwards compatibility alias for DeliveriesListState
typedef DeliveriesListState = DeliveriesState;
