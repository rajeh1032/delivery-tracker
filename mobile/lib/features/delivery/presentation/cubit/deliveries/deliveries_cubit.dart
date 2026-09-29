import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/get_deliveries_use_case.dart';
import 'deliveries_state.dart';

/// Cubit managing deliveries list fetching, local cache updates, searching, and filtering.
@injectable
class DeliveriesCubit extends Cubit<DeliveriesState> {
  final GetDeliveriesUseCase _getDeliveriesUseCase;
  final DeliveryRepository _deliveryRepository;
  final ConnectivityService connectivityService;

  StreamSubscription<List<DeliveryEntity>>? _deliveriesSubscription;

  DeliveriesCubit(
    this._getDeliveriesUseCase,
    this._deliveryRepository,
    this.connectivityService,
  ) : super(const DeliveriesState()) {
    _startWatchingDeliveries();
  }

  void _startWatchingDeliveries() {
    _deliveriesSubscription = _deliveryRepository
        .watchDeliveries()
        .listen(_onDeliveriesUpdated);
  }

  void _onDeliveriesUpdated(List<DeliveryEntity> updatedList) {
    if (isClosed) return;

    if (state.status == DeliveriesStatus.initial ||
        state.status == DeliveriesStatus.loading) {
      emit(state.copyWith(
        status: updatedList.isEmpty
            ? DeliveriesStatus.empty
            : DeliveriesStatus.loaded,
        deliveries: updatedList,
      ));
    } else {
      emit(state.copyWith(
        deliveries: updatedList,
        status: updatedList.isEmpty
            ? DeliveriesStatus.empty
            : DeliveriesStatus.loaded,
      ));
    }
  }

  /// Initial load of deliveries from repository (cache-first policy).
  Future<void> loadDeliveries() async {
    if (state.deliveries.isEmpty) {
      emit(state.copyWith(status: DeliveriesStatus.loading));
    }

    final result = await _getDeliveriesUseCase.invoke();

    if (isClosed) return;

    if (result case ApiSuccessResult<List<DeliveryEntity>>(:final data)) {
      emit(state.copyWith(
        status: data.isEmpty
            ? DeliveriesStatus.empty
            : DeliveriesStatus.loaded,
        deliveries: data,
        errorMessage: null,
      ));
    } else if (result case ApiErrorResult<List<DeliveryEntity>>(:final failure)) {
      if (state.deliveries.isNotEmpty) {
        emit(state.copyWith(
          status: DeliveriesStatus.loaded,
          errorMessage: failure.errorMessage,
        ));
      } else {
        emit(state.copyWith(
          status: DeliveriesStatus.error,
          errorMessage: failure.errorMessage,
        ));
      }
    }
  }

  /// Refreshes deliveries from remote without clearing active view.
  Future<void> refresh() async {
    final result = await _getDeliveriesUseCase.invoke();
    if (isClosed) return;

    if (result case ApiSuccessResult<List<DeliveryEntity>>(:final data)) {
      emit(state.copyWith(
        deliveries: data,
        status: data.isEmpty
            ? DeliveriesStatus.empty
            : DeliveriesStatus.loaded,
        errorMessage: null,
      ));
    }
  }

  /// Updates active search query for real-time filtering.
  void searchChanged(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Updates active status chip filter.
  void filterChanged(DeliveryStatusFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  @override
  Future<void> close() async {
    await _deliveriesSubscription?.cancel();
    return super.close();
  }
}

/// Backwards compatibility alias
typedef DeliveriesListCubit = DeliveriesCubit;
