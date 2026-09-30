import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../features/delivery/data_sources/mapper/to_entity_mapper.dart';
import '../../features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import '../../features/delivery/data_sources/models/request/fail_delivery_request_dto.dart';
import '../../features/delivery/data_sources/models/response/delivery_response_dto.dart';
import '../../features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import '../../features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import '../../features/delivery/domain/entities/delivery_action.dart';
import '../network/api_results.dart';
import '../network/failures.dart';
import '../network/network_constants.dart';
import '../utils/enums.dart';
import 'proof_storage_service.dart';

class DeliveryActionSyncer {
  final DeliveryLocalDataSource _local;
  final DeliveryRemoteDs _remote;
  final ProofStorageService _proofs;

  const DeliveryActionSyncer(this._local, this._remote, this._proofs);

  Future<bool> sync(DeliveryAction action) async {
    final current = await _local.getDeliveryById(action.deliveryId);
    if (current != null) {
      await _local.updateDelivery(
        current.copyWith(syncStatus: SyncStatus.syncing),
      );
    }
    final path = action.payload[NetworkConstants.keyLocalPhotoPath]?.toString();
    if (path != null && path.isNotEmpty) {
      final photo = _proofs.getProofFile(path);
      if (photo == null) {
        return _persistFailure(
          action,
          const ApiErrorResult(
            NetworkConstants.proofFileMissing,
            code: NetworkConstants.proofFileMissing,
          ),
        );
      }
      final upload = await _remote.uploadProof(action.deliveryId, photo);
      if (upload is ApiErrorResult<ProofUploadResponseDto>) {
        return _persistFailure(action, upload);
      }
    }
    final result = action.type == DeliveryActionType.complete
        ? await _remote.completeDelivery(
            action.deliveryId,
            CompleteDeliveryRequestDto(
              recipientName:
                  action.payload[NetworkConstants.keyRecipientName]
                      ?.toString() ??
                  '',
              note: action.payload[NetworkConstants.keyNote]?.toString(),
              clientActionId: action.clientActionId,
              baseVersion:
                  action.payload[NetworkConstants.keyBaseVersion] as int?,
            ),
          )
        : await _remote.failDelivery(
            action.deliveryId,
            FailDeliveryRequestDto(
              reason:
                  action.payload[NetworkConstants.keyReason]?.toString() ?? '',
              note: action.payload[NetworkConstants.keyNote]?.toString(),
              clientActionId: action.clientActionId,
              baseVersion:
                  action.payload[NetworkConstants.keyBaseVersion] as int?,
            ),
          );
    return _handleResult(action, result);
  }

  Future<bool> _handleResult(
    DeliveryAction action,
    ApiResult<DeliveryActionResponseDto> result,
  ) async {
    if (result is ApiSuccessResult<DeliveryActionResponseDto>) {
      final delivery = result.data.delivery.toEntity().copyWith(
        syncStatus: SyncStatus.synced,
      );
      try {
        await _local.updateDelivery(delivery);
      } on HiveError catch (error) {
        return _persistStorageFailure(action, error);
      } on FileSystemException catch (error) {
        return _persistStorageFailure(action, error);
      }
      await _local.deletePendingAction(action.clientActionId);
      await _cleanupProof(action);
      return true;
    }
    final error = result as ApiErrorResult<DeliveryActionResponseDto>;

    final isConflict =
        error.statusCode == NetworkConstants.statusConflict ||
        error.code == NetworkConstants.deliveryConflict;
    if (isConflict) {
      return _reconcileConflict(action);
    }

    return _persistFailure(action, error);
  }

  Future<bool> _reconcileConflict(DeliveryAction action) async {
    try {
      final refreshed = await _remote.getDeliveryById(action.deliveryId);
      if (refreshed is ApiSuccessResult<DeliveryResponseDto>) {
        await _local.updateDelivery(
          refreshed.data.toEntity().copyWith(syncStatus: SyncStatus.synced),
        );
        await _local.deletePendingAction(action.clientActionId);
        await _cleanupProof(action);
        return false;
      }
      final error = refreshed as ApiErrorResult<DeliveryResponseDto>;
      return _persistFailure(
        action,
        ApiErrorResult(
          error.message,
          code: error.code,
          statusCode: error.statusCode,
          failure: error.failure,
        ),
      );
    } on HiveError catch (error) {
      return _persistStorageFailure(action, error);
    } on FileSystemException catch (error) {
      return _persistStorageFailure(action, error);
    }
  }

  Future<bool> _persistStorageFailure(DeliveryAction action, Object error) =>
      _persistFailure(
        action,
        ApiErrorResult(
          error.toString(),
          failure: TransientFailure(errorMessage: error.toString()),
        ),
      );

  Future<bool> _persistFailure<T>(
    DeliveryAction action,
    ApiErrorResult<T> result,
  ) async {
    final transient =
        result.failure.isRetryable ||
        result.statusCode == NetworkConstants.statusInternalServerError ||
        result.statusCode == null;
    await _local.savePendingAction(
      action.copyWith(
        retryCount: transient ? action.retryCount + 1 : action.retryCount,
        status: SyncStatus.failed,
        lastError: result.message,
      ),
    );
    final cached = await _local.getDeliveryById(action.deliveryId);
    if (cached != null) {
      await _local.updateDelivery(
        cached.copyWith(syncStatus: SyncStatus.failed),
      );
    }
    return false;
  }

  Future<void> _cleanupProof(DeliveryAction action) async {
    final path = action.payload[NetworkConstants.keyLocalPhotoPath]?.toString();
    if (path == null) return;
    try {
      await _proofs.deleteProofFile(path);
    } on FileSystemException catch (error) {
      debugPrint('Unable to remove synced proof file: $error');
    }
  }
}
