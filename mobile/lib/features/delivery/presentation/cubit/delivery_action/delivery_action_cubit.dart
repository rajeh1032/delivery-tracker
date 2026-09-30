import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/complete_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/fail_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/complete_delivery_use_case.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/fail_delivery_use_case.dart';
import 'delivery_action_state.dart';

/// Unified Cubit managing delivery action workflow (Complete / Fail),
/// photo proof capture, and mutation submission.
@injectable
class DeliveryActionCubit extends Cubit<DeliveryActionState> {
  final CompleteDeliveryUseCase _completeDeliveryUseCase;
  final FailDeliveryUseCase _failDeliveryUseCase;
  final ProofStorageService _proofStorageService;
  final SyncManager _syncManager;
  final ImagePicker _imagePicker;
  final Uuid _uuid;

  DeliveryActionCubit(
    this._completeDeliveryUseCase,
    this._failDeliveryUseCase,
    this._proofStorageService,
    this._syncManager, {
    @ignoreParam ImagePicker? imagePicker,
    Uuid uuid = const Uuid(),
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _uuid = uuid,
       super(DeliveryActionState(clientActionId: uuid.v4()));

  void recipientNameChanged(String value) {
    emit(state.copyWith(recipientName: value));
  }

  void reasonChanged(FailureReason reason) {
    emit(state.copyWith(reason: reason));
  }

  void noteChanged(String value) {
    emit(state.copyWith(note: value));
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (state.isPickingPhoto || state.isSubmitting) return;

    emit(state.copyWith(status: DeliveryActionStatus.pickingPhoto));

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (picked != null) {
        final durablePath = await _proofStorageService.saveProofFile(
          File(picked.path),
          state.clientActionId,
        );
        emit(
          state.copyWith(
            status: DeliveryActionStatus.initial,
            photoPath: durablePath,
            photoError: null,
          ),
        );
      } else {
        emit(state.copyWith(status: DeliveryActionStatus.initial));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DeliveryActionStatus.initial,
          photoError: e.toString(),
        ),
      );
    }
  }

  void removePhoto() {
    emit(state.copyWith(clearPhoto: true));
  }

  Future<bool> completeDelivery(DeliveryEntity delivery) async {
    if (state.isSubmitting) return false;

    final trimmedName = state.recipientName.trim();
    if (trimmedName.length < 2) {
      emit(
        state.copyWith(
          status: DeliveryActionStatus.failure,
          actionType: DeliveryActionType.complete,
          errorMessage: 'Recipient name is required',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: DeliveryActionStatus.submitting,
        actionType: DeliveryActionType.complete,
      ),
    );

    final request = CompleteDeliveryRequestEntity(
      deliveryId: delivery.id,
      recipientName: trimmedName,
      note: state.note.trim().isEmpty ? null : state.note.trim(),
      clientActionId: state.clientActionId,
      baseVersion: delivery.version,
      localPhotoPath: state.photoPath,
    );

    final result = await _completeDeliveryUseCase.invoke(request);

    switch (result) {
      case ApiSuccessResult<DeliveryEntity>():
        emit(
          state.copyWith(
            status: DeliveryActionStatus.success,
            actionType: DeliveryActionType.complete,
          ),
        );
        unawaited(_syncManager.processQueue());
        return true;
      case ApiErrorResult<DeliveryEntity>(:final failure):
        emit(
          state.copyWith(
            status: DeliveryActionStatus.failure,
            actionType: DeliveryActionType.complete,
            errorMessage: failure.errorMessage,
          ),
        );
        return false;
    }
  }

  Future<bool> failDelivery(DeliveryEntity delivery) async {
    if (state.isSubmitting) return false;

    if (state.reason == null) {
      emit(
        state.copyWith(
          status: DeliveryActionStatus.failure,
          actionType: DeliveryActionType.fail,
          errorMessage: 'Please select a failure reason',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: DeliveryActionStatus.submitting,
        actionType: DeliveryActionType.fail,
      ),
    );

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
        emit(
          state.copyWith(
            status: DeliveryActionStatus.success,
            actionType: DeliveryActionType.fail,
          ),
        );
        unawaited(_syncManager.processQueue());
        return true;
      case ApiErrorResult<DeliveryEntity>(:final failure):
        emit(
          state.copyWith(
            status: DeliveryActionStatus.failure,
            actionType: DeliveryActionType.fail,
            errorMessage: failure.errorMessage,
          ),
        );
        return false;
    }
  }

  void reset() {
    emit(DeliveryActionState(clientActionId: _uuid.v4()));
  }
}
