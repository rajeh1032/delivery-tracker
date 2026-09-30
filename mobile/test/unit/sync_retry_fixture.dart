import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/services/sync_retry_policy.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:mocktail/mocktail.dart';

class _Local extends Mock implements DeliveryLocalDataSource {}

class _Remote extends Mock implements DeliveryRemoteDs {}

class _Connectivity extends Mock implements ConnectivityService {}

class _Proofs extends Mock implements ProofStorageService {}

class RetryFixture {
  final local = _Local();
  final remote = _Remote();
  final connectivity = _Connectivity();
  final proofs = _Proofs();
  late SyncManager manager;
  final action = DeliveryAction(
    clientActionId: 'stable-id',
    deliveryId: 7,
    type: DeliveryActionType.complete,
    payload: const {'recipient_name': 'Sam'},
    createdAt: DateTime.utc(2026),
  );
  late List<DeliveryAction> queue;
  var delivery = const DeliveryEntity(
    id: 7,
    orderNumber: 'ORD-7',
    customerName: 'Sam',
    phone: '555',
    address: 'Town',
    amountDue: 10,
    status: DeliveryStatus.delivered,
    syncStatus: SyncStatus.waitingToSync,
  );
  var calls = 0;
  var reachable = true;
  final sentIds = <String>[];
  ApiResult<DeliveryActionResponseDto> response = const ApiErrorResult(
    'Server failed',
    statusCode: 500,
    failure: TransientFailure(errorMessage: 'Server failed'),
  );
  RetryFixture({SyncRetryPolicy? policy}) {
    queue = [action];
    registerFallbackValue(action);
    registerFallbackValue(delivery);
    registerFallbackValue(
      const CompleteDeliveryRequestDto(
        recipientName: 'Sam',
        clientActionId: 'fallback',
      ),
    );
    when(
      () => connectivity.checkReachability(),
    ).thenAnswer((_) async => reachable);
    when(() => local.getPendingActions()).thenAnswer((_) async => [...queue]);
    when(() => local.getDeliveryById(7)).thenAnswer((_) async => delivery);
    when(() => local.updateDelivery(any())).thenAnswer((call) async {
      delivery = call.positionalArguments.single as DeliveryEntity;
    });
    when(() => local.savePendingAction(any())).thenAnswer((call) async {
      final updated = call.positionalArguments.single as DeliveryAction;
      queue.removeWhere((a) => a.clientActionId == updated.clientActionId);
      queue.add(updated);
    });
    when(() => local.deletePendingAction(any())).thenAnswer((call) async {
      queue.removeWhere(
        (a) => a.clientActionId == call.positionalArguments.single,
      );
    });
    when(() => remote.completeDelivery(7, any())).thenAnswer((call) async {
      calls++;
      sentIds.add(
        (call.positionalArguments[1] as CompleteDeliveryRequestDto)
            .clientActionId,
      );
      return response;
    });
    manager = SyncManager(
      local,
      remote,
      connectivity,
      proofs,
      retryPolicy: policy,
    );
  }
}
