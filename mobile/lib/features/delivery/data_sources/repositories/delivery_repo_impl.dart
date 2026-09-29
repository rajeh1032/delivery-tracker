import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/network/network_constants.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/delivery_action.dart';
import '../../domain/entities/delivery_entity.dart';
import '../../domain/entities/request/complete_delivery_request_entity.dart';
import '../../domain/entities/request/fail_delivery_request_entity.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../mapper/to_entity_mapper.dart';
import '../models/response/delivery_response_dto.dart';
import '../sources/local/delivery_local_ds.dart';
import '../sources/remote/delivery_remote_ds.dart';

@Injectable(as: DeliveryRepository)
class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryLocalDataSource _localDataSource;
  final DeliveryRemoteDs _remoteDataSource;

  DeliveryRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
  );

  @override
  Future<ApiResult<List<DeliveryEntity>>> getDeliveries() async {
    final remoteResult = await _remoteDataSource.getDeliveries();
    if (remoteResult is ApiSuccessResult<List<DeliveryResponseDto>>) {
      final entities = remoteResult.data.toEntities();
      await _localDataSource.cacheDeliveries(entities);
      return ApiSuccessResult(entities);
    }

    final cached = await _localDataSource.getDeliveries();
    if (cached.isNotEmpty) {
      return ApiSuccessResult(cached);
    }

    if (remoteResult is ApiErrorResult) {
      final error = remoteResult as ApiErrorResult;
      return ApiErrorResult(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
        failure: error.failure,
      );
    }

    return const ApiErrorResult('Failed to load deliveries');
  }

  @override
  Future<ApiResult<DeliveryEntity>> getDeliveryById(int id) async {
    final cached = await _localDataSource.getDeliveryById(id);
    final remoteResult = await _remoteDataSource.getDeliveryById(id);

    if (remoteResult is ApiSuccessResult<DeliveryResponseDto>) {
      final entity = remoteResult.data.toEntity();
      await _localDataSource.updateDelivery(entity);
      return ApiSuccessResult(entity);
    }

    if (cached != null) {
      return ApiSuccessResult(cached);
    }

    if (remoteResult is ApiErrorResult) {
      final error = remoteResult as ApiErrorResult;
      return ApiErrorResult(
        error.message,
        code: error.code,
        statusCode: error.statusCode,
        failure: error.failure,
      );
    }

    return const ApiErrorResult('Delivery not found');
  }

  @override
  Future<void> submitAction(DeliveryAction action) async {
    await _localDataSource.savePendingAction(action);

    final existing = await _localDataSource.getDeliveryById(action.deliveryId);
    if (existing != null) {
      final newStatus = action.type == DeliveryActionType.complete
          ? DeliveryStatus.delivered
          : DeliveryStatus.failed;

      final updated = existing.copyWith(
        status: newStatus,
        syncStatus: SyncStatus.waitingToSync,
        clientActionId: action.clientActionId,
      );
      await _localDataSource.updateDelivery(updated);
    }
  }

  @override
  Future<ApiResult<DeliveryEntity>> completeDelivery(
    CompleteDeliveryRequestEntity request,
  ) async {
    final action = DeliveryAction(
      clientActionId: request.clientActionId,
      deliveryId: request.deliveryId,
      type: DeliveryActionType.complete,
      payload: {
        NetworkConstants.keyRecipientName: request.recipientName,
        if (request.note != null) NetworkConstants.keyNote: request.note,
        if (request.baseVersion != null)
          NetworkConstants.keyBaseVersion: request.baseVersion,
        if (request.localPhotoPath != null)
          NetworkConstants.keyLocalPhotoPath: request.localPhotoPath,
      },
      status: SyncStatus.waitingToSync,
      createdAt: DateTime.now(),
    );

    await submitAction(action);

    final updated = await _localDataSource.getDeliveryById(request.deliveryId);
    if (updated != null) {
      return ApiSuccessResult(updated);
    }

    return const ApiErrorResult(
      'Delivery not found in local cache',
      failure: Failure(errorMessage: 'Delivery not found in local cache'),
    );
  }

  @override
  Future<ApiResult<DeliveryEntity>> failDelivery(
    FailDeliveryRequestEntity request,
  ) async {
    final action = DeliveryAction(
      clientActionId: request.clientActionId,
      deliveryId: request.deliveryId,
      type: DeliveryActionType.fail,
      payload: {
        NetworkConstants.keyReason: request.reason.toApiKey(),
        if (request.note != null) NetworkConstants.keyNote: request.note,
        if (request.baseVersion != null)
          NetworkConstants.keyBaseVersion: request.baseVersion,
      },
      status: SyncStatus.waitingToSync,
      createdAt: DateTime.now(),
    );

    await submitAction(action);

    final updated = await _localDataSource.getDeliveryById(request.deliveryId);
    if (updated != null) {
      return ApiSuccessResult(updated);
    }

    return const ApiErrorResult(
      'Delivery not found in local cache',
      failure: Failure(errorMessage: 'Delivery not found in local cache'),
    );
  }

  @override
  Stream<List<DeliveryEntity>> watchDeliveries() {
    return _localDataSource.watchDeliveries();
  }
}
