import 'dart:async';
import 'package:injectable/injectable.dart';

import '../../features/delivery/data_sources/mapper/to_entity_mapper.dart';
import '../../features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import '../../features/delivery/data_sources/models/request/fail_delivery_request_dto.dart';
import '../../features/delivery/data_sources/models/response/delivery_response_dto.dart';
import '../../features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import '../../features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import '../../features/delivery/domain/entities/delivery_action.dart';
import '../network/api_results.dart';
import '../network/network_constants.dart';
import '../utils/enums.dart';
import 'connectivity_service.dart';
import 'proof_storage_service.dart';

@lazySingleton
class SyncManager {
  final DeliveryLocalDataSource _localDataSource;
  final DeliveryRemoteDs _remoteDataSource;
  final ConnectivityService _connectivityService;
  final ProofStorageService _proofStorageService;

  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _debounceTimer;

  SyncManager(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivityService,
    this._proofStorageService,
  );

  bool get isSyncing => _isSyncing;

  void startListening({Duration debounce = const Duration(seconds: 5)}) {
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(debounce, () {
          processQueue();
        });
      }
    });
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final isReachable = await _connectivityService.checkReachability();
      if (!isReachable) {
        return;
      }

      final pendingActions = await _localDataSource.getPendingActions();
      for (final action in pendingActions) {
        await syncAction(action);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> syncAction(DeliveryAction action) async {
    final currentDelivery =
        await _localDataSource.getDeliveryById(action.deliveryId);
    if (currentDelivery != null) {
      await _localDataSource.updateDelivery(
        currentDelivery.copyWith(syncStatus: SyncStatus.syncing),
      );
    }

    final photoPath =
        action.payload[NetworkConstants.keyLocalPhotoPath]?.toString();
    if (photoPath != null && photoPath.isNotEmpty) {
      final photoFile = _proofStorageService.getProofFile(photoPath);
      if (photoFile != null) {
        await _remoteDataSource.uploadProof(action.deliveryId, photoFile);
      }
    }

    final ApiResult<DeliveryActionResponseDto> result;
    if (action.type == DeliveryActionType.complete) {
      final requestDto = CompleteDeliveryRequestDto(
        recipientName:
            action.payload[NetworkConstants.keyRecipientName]?.toString() ?? '',
        note: action.payload[NetworkConstants.keyNote]?.toString(),
        clientActionId: action.clientActionId,
        baseVersion: action.payload[NetworkConstants.keyBaseVersion] as int?,
      );
      result = await _remoteDataSource.completeDelivery(
        action.deliveryId,
        requestDto,
      );
    } else {
      final requestDto = FailDeliveryRequestDto(
        reason:
            action.payload[NetworkConstants.keyReason]?.toString() ?? '',
        note: action.payload[NetworkConstants.keyNote]?.toString(),
        clientActionId: action.clientActionId,
        baseVersion: action.payload[NetworkConstants.keyBaseVersion] as int?,
      );
      result = await _remoteDataSource.failDelivery(
        action.deliveryId,
        requestDto,
      );
    }

    return await _handleSyncResult(action, result);
  }

  Future<bool> _handleSyncResult(
    DeliveryAction action,
    ApiResult<DeliveryActionResponseDto> result,
  ) async {
    if (result is ApiSuccessResult<DeliveryActionResponseDto>) {
      await _localDataSource.deletePendingAction(action.clientActionId);

      final updatedDelivery = result.data.delivery.toEntity().copyWith(
            syncStatus: SyncStatus.synced,
          );
      await _localDataSource.updateDelivery(updatedDelivery);

      final photoPath =
          action.payload[NetworkConstants.keyLocalPhotoPath]?.toString();
      if (photoPath != null) {
        await _proofStorageService.deleteProofFile(photoPath);
      }

      return true;
    }

    if (result is ApiErrorResult<DeliveryActionResponseDto>) {
      final isConflict = result.statusCode == NetworkConstants.statusConflict ||
          result.code == NetworkConstants.deliveryConflict;

      if (isConflict) {
        final serverDeliveryResult =
            await _remoteDataSource.getDeliveryById(action.deliveryId);
        if (serverDeliveryResult is ApiSuccessResult<DeliveryResponseDto>) {
          final serverTruth = serverDeliveryResult.data.toEntity().copyWith(
                syncStatus: SyncStatus.synced,
              );
          await _localDataSource.updateDelivery(serverTruth);
        }

        await _localDataSource.deletePendingAction(action.clientActionId);
        return false;
      }

      final isTransient = result.failure.isRetryable ||
          result.statusCode == NetworkConstants.statusInternalServerError ||
          result.statusCode == null;

      final updatedAction = action.copyWith(
        retryCount: isTransient ? action.retryCount + 1 : action.retryCount,
        status: SyncStatus.failed,
        lastError: result.message,
      );
      await _localDataSource.savePendingAction(updatedAction);

      final local = await _localDataSource.getDeliveryById(action.deliveryId);
      if (local != null) {
        await _localDataSource.updateDelivery(
          local.copyWith(syncStatus: SyncStatus.failed),
        );
      }

      return false;
    }

    return false;
  }

  Future<bool> retryAction(String clientActionId) async {
    final pendingActions = await _localDataSource.getPendingActions();
    final matchingAction = pendingActions.where(
      (a) => a.clientActionId == clientActionId,
    );

    if (matchingAction.isEmpty) {
      return false;
    }

    final isReachable = await _connectivityService.checkReachability();
    if (!isReachable) {
      return false;
    }

    return await syncAction(matchingAction.first);
  }

  void dispose() {
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}
