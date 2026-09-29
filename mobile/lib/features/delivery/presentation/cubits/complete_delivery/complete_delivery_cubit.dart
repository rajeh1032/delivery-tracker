import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/request/complete_delivery_request_entity.dart';
import 'package:delivery_tracker/features/delivery/domain/use_case/complete_delivery_use_case.dart';
import 'complete_delivery_state.dart';

/// Cubit managing complete delivery form state, durable photo proof, and mutation submission.
@injectable
class CompleteDeliveryCubit extends Cubit<CompleteDeliveryState> {
  final CompleteDeliveryUseCase _completeDeliveryUseCase;
  final ProofStorageService _proofStorageService;
  final SyncManager _syncManager;
  final ImagePicker _imagePicker;

  CompleteDeliveryCubit(
    this._completeDeliveryUseCase,
    this._proofStorageService,
    this._syncManager, {
    ImagePicker? imagePicker,
    Uuid uuid = const Uuid(),
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        super(CompleteDeliveryState(clientActionId: uuid.v4()));

  void recipientNameChanged(String value) {
    emit(state.copyWith(recipientName: value));
  }

  void noteChanged(String value) {
    emit(state.copyWith(note: value));
  }

  Future<void> pickPhoto(ImageSource source) async {
    if (state.isPickingPhoto || state.isSubmitting) return;

    emit(state.copyWith(status: CompleteDeliveryStatus.pickingPhoto));

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
        emit(state.copyWith(
          status: CompleteDeliveryStatus.editing,
          photoPath: durablePath,
          photoError: null,
        ));
      } else {
        emit(state.copyWith(status: CompleteDeliveryStatus.editing));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CompleteDeliveryStatus.editing,
        photoError: e.toString(),
      ));
    }
  }

  void removePhoto() {
    emit(state.copyWith(clearPhoto: true));
  }

  Future<bool> confirm(DeliveryEntity delivery) async {
    if (state.isSubmitting) return false;

    final trimmedName = state.recipientName.trim();
    if (trimmedName.length < 2) {
      emit(state.copyWith(
        status: CompleteDeliveryStatus.failure,
        submissionError: 'Recipient name is required',
      ));
      return false;
    }

    emit(state.copyWith(status: CompleteDeliveryStatus.submitting));

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
        emit(state.copyWith(status: CompleteDeliveryStatus.success));
        unawaited(_syncManager.processQueue());
        return true;
      case ApiErrorResult<DeliveryEntity>(:final failure):
        emit(state.copyWith(
          status: CompleteDeliveryStatus.failure,
          submissionError: failure.errorMessage,
        ));
        return false;
    }
  }
}
