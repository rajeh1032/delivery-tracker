import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/get_delivery_by_id_use_case.dart';
import 'delivery_details_state.dart';

/// Business logic cubit managing delivery details and reactive sync badge updates.
@injectable
class DeliveryDetailsCubit extends Cubit<DeliveryDetailsState> {
  final GetDeliveryByIdUseCase _getDeliveryByIdUseCase;
  final DeliveryRepository _deliveryRepository;

  int? _deliveryId;
  StreamSubscription<List<DeliveryEntity>>? _deliveriesSubscription;

  DeliveryDetailsCubit(
    this._getDeliveryByIdUseCase,
    this._deliveryRepository,
  ) : super(const DeliveryDetailsState()) {
    _subscribeToDeliveries();
  }

  void _subscribeToDeliveries() {
    _deliveriesSubscription = _deliveryRepository.watchDeliveries().listen(
      (deliveries) {
        if (_deliveryId == null) return;
        final index = deliveries.indexWhere((d) => d.id == _deliveryId);
        if (index != -1) {
          emit(state.copyWith(
            status: DeliveryDetailsStatus.loaded,
            delivery: deliveries[index],
            errorMessage: null,
          ));
        }
      },
      onError: (_) {},
    );
  }

  /// Loads delivery by ID with optional preloaded entity for instant render.
  Future<void> loadDelivery(int id, {DeliveryEntity? preloaded}) async {
    _deliveryId = id;
    if (preloaded != null) {
      emit(state.copyWith(
        status: DeliveryDetailsStatus.loaded,
        delivery: preloaded,
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        status: DeliveryDetailsStatus.loading,
        errorMessage: null,
      ));
    }

    final result = await _getDeliveryByIdUseCase.invoke(id);
    switch (result) {
      case ApiSuccessResult<DeliveryEntity>(:final data):
        emit(state.copyWith(
          status: DeliveryDetailsStatus.loaded,
          delivery: data,
          errorMessage: null,
        ));
      case ApiErrorResult<DeliveryEntity>(:final failure):
        if (state.delivery == null) {
          if (failure.code == '404' ||
              failure.errorMessage == NetworkConstants.resourceNotFoundMessage) {
            emit(state.copyWith(
              status: DeliveryDetailsStatus.notFound,
              errorMessage: failure.errorMessage,
            ));
          } else {
            emit(state.copyWith(
              status: DeliveryDetailsStatus.error,
              errorMessage: failure.errorMessage,
            ));
          }
        }
    }
  }

  @override
  Future<void> close() {
    _deliveriesSubscription?.cancel();
    return super.close();
  }
}
