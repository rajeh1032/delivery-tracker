import 'package:equatable/equatable.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';

/// Screen-level UI states for the deliveries list.
enum DeliveriesListStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// Filter options for segmenting deliveries by status.
enum DeliveryStatusFilter {
  all,
  pending,
  delivered,
  failed,
}

/// Immutable state for the DeliveriesListCubit.
class DeliveriesListState extends Equatable {
  final DeliveriesListStatus status;
  final List<DeliveryEntity> deliveries;
  final String searchQuery;
  final DeliveryStatusFilter filter;
  final String? errorMessage;

  const DeliveriesListState({
    this.status = DeliveriesListStatus.initial,
    this.deliveries = const [],
    this.searchQuery = '',
    this.filter = DeliveryStatusFilter.all,
    this.errorMessage,
  });

  /// Deliveries filtered by selected status chip and search query.
  List<DeliveryEntity> get visibleDeliveries {
    return deliveries.where((d) {
      // 1. Status Filter
      final matchesFilter = switch (filter) {
        DeliveryStatusFilter.all => true,
        DeliveryStatusFilter.pending => d.status == DeliveryStatus.pending,
        DeliveryStatusFilter.delivered => d.status == DeliveryStatus.delivered,
        DeliveryStatusFilter.failed => d.status == DeliveryStatus.failed,
      };
      if (!matchesFilter) return false;

      // 2. Search Query (orderNumber, customerName, address)
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

  bool get isLoading => status == DeliveriesListStatus.loading;
  bool get isInitial => status == DeliveriesListStatus.initial;

  DeliveriesListState copyWith({
    DeliveriesListStatus? status,
    List<DeliveryEntity>? deliveries,
    String? searchQuery,
    DeliveryStatusFilter? filter,
    String? errorMessage,
  }) {
    return DeliveriesListState(
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
