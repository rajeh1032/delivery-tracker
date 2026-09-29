import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/fail_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/fail_delivery_use_case.dart';
import 'fail_delivery_state.dart';

/// Cubit managing failed delivery form state and mutation submission.
@injectable
class FailDeliveryCubit extends Cubit<FailDeliveryState> {
  final FailDeliveryUseCase _failDeliveryUseCase;
  final SyncManager _syncManager;

  FailDeliveryCubit(
    this._failDeliveryUseCase,
    this._syncManager, {
    Uuid uuid = const Uuid(),
  }) : super(FailDeliveryState(clientActionId: uuid.v4()));

  void reasonChanged(FailureReason reason) {
    emit(state.copyWith(reason: reason));
  }

  void noteChanged(String value) {
    emit(state.copyWith(note: value));
  }

  Future<bool> confirm(DeliveryEntity delivery) async {
    if (state.isSubmitting) return false;

    if (state.reason == null) {
      emit(state.copyWith(
        status: FailDeliveryStatus.failure,
        submissionError: 'Please select a failure reason',
      ));
      return false;
    }

    emit(state.copyWith(status: FailDeliveryStatus.submitting));

    final request = FailDeliveryRequestEntity(
      deliveryId: delivery.id,
      reason: state.reason!,
      note: state.note.trim().isEmpty ? null : state.note.trim(),
      clientActionId: state.clientActionId,
      baseVersion: delivery.version,
    );

    final result = await _failDeliveryUseCase.invoke(request);

    switch (result) {
      case ApiSuccessResult<DeliveryEntity>():
        emit(state.copyWith(status: FailDeliveryStatus.success));
        unawaited(_syncManager.processQueue());
        return true;
      case ApiErrorResult<DeliveryEntity>(:final failure):
        emit(state.copyWith(
          status: FailDeliveryStatus.failure,
          submissionError: failure.errorMessage,
        ));
        return false;
    }
  }
}
