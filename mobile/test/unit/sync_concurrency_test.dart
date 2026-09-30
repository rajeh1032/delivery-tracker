import 'dart:async';

import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/network_constants.dart';
import 'package:delivery_tracker/core/services/connectivity_service.dart';
import 'package:delivery_tracker/core/services/proof_storage_service.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/request/complete_delivery_request_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/models/response/delivery_response_dto.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import 'package:delivery_tracker/features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_action.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Local extends Mock implements DeliveryLocalDataSource {}

class _Remote extends Mock implements DeliveryRemoteDs {}

class _Connectivity extends Mock implements ConnectivityService {}

class _Proofs extends Mock implements ProofStorageService {}

DeliveryAction _action(String id, int deliveryId) => DeliveryAction(
  clientActionId: id,
  deliveryId: deliveryId,
  type: DeliveryActionType.complete,
  payload: const {NetworkConstants.keyRecipientName: 'Sam'},
  createdAt: DateTime.utc(2026),
);

DeliveryEntity _delivery(int id) => DeliveryEntity(
  id: id,
  orderNumber: 'ORD-$id',
  customerName: 'Sam',
  phone: '555',
  address: 'Town',
  amountDue: 10,
  status: DeliveryStatus.pending,
);

DeliveryActionResponseDto _response(int id) => DeliveryActionResponseDto(
  message: 'ok',
  delivery: DeliveryResponseDto(
    id: id,
    orderNumber: 'ORD-$id',
    customerName: 'Sam',
    phone: '555',
    address: 'Town',
    amountDue: 10,
    status: 'delivered',
    version: 2,
  ),
);

void main() {
  late _Local local;
  late _Remote remote;
  late _Connectivity connectivity;
  late SyncManager manager;
  final queue = <DeliveryAction>[];
  var active = 0;
  var maximumActive = 0;
  var mutationCalls = 0;

  setUpAll(() {
    registerFallbackValue(_delivery(1));
    registerFallbackValue(_action('fallback', 1));
    registerFallbackValue(
      const CompleteDeliveryRequestDto(
        recipientName: 'Sam',
        clientActionId: 'fallback',
      ),
    );
  });

  setUp(() {
    local = _Local();
    remote = _Remote();
    connectivity = _Connectivity();
    manager = SyncManager(local, remote, connectivity, _Proofs());
    queue.clear();
    active = maximumActive = mutationCalls = 0;
    when(() => connectivity.checkReachability()).thenAnswer((_) async => true);
    when(() => local.getPendingActions()).thenAnswer((_) async => [...queue]);
    when(() => local.getDeliveryById(any())).thenAnswer(
      (call) async => _delivery(call.positionalArguments.single as int),
    );
    when(() => local.updateDelivery(any())).thenAnswer((_) async {});
    when(() => local.deletePendingAction(any())).thenAnswer((call) async {
      queue.removeWhere(
        (action) => action.clientActionId == call.positionalArguments.single,
      );
    });
    when(() => remote.completeDelivery(any(), any())).thenAnswer((call) async {
      final id = (call.positionalArguments[0] as int);
      mutationCalls++;
      active++;
      if (active > maximumActive) maximumActive = active;
      active--;
      return ApiSuccessResult(_response(id));
    });
  });
  tearDown(() => manager.dispose());

  test(
    'manual retry waits for drain and does not resend completed action',
    () async {
      final action = _action('one', 1);
      queue.add(action);
      final started = Completer<void>();
      final release = Completer<ApiResult<DeliveryActionResponseDto>>();
      when(() => remote.completeDelivery(1, any())).thenAnswer((_) {
        mutationCalls++;
        active++;
        if (active > maximumActive) maximumActive = active;
        if (!started.isCompleted) started.complete();
        return release.future.whenComplete(() => active--);
      });

      final drain = manager.processQueue();
      await started.future;
      final retry = manager.retryAction(action.clientActionId);
      release.complete(ApiSuccessResult(_response(1)));
      await drain;

      expect(await retry, isFalse);
      expect(mutationCalls, 1);
      expect(maximumActive, 1);
    },
  );

  test(
    'two concurrent retries of one action make one remote mutation',
    () async {
      final action = _action('same', 1);
      queue.add(action);
      final started = Completer<void>();
      final release = Completer<ApiResult<DeliveryActionResponseDto>>();
      when(() => remote.completeDelivery(1, any())).thenAnswer((_) {
        mutationCalls++;
        active++;
        if (active > maximumActive) maximumActive = active;
        started.complete();
        return release.future.whenComplete(() => active--);
      });

      final first = manager.retryAction(action.clientActionId);
      await started.future;
      final second = manager.retryAction(action.clientActionId);
      release.complete(ApiSuccessResult(_response(1)));

      expect(await first, isTrue);
      expect(await second, isFalse);
      expect(mutationCalls, 1);
      expect(maximumActive, 1);
    },
  );

  test('retries for two actions serialize with a background drain', () async {
    final first = _action('first', 1);
    final second = _action('second', 2);
    queue.addAll([first, second]);
    final started = Completer<void>();
    final release = Completer<void>();
    when(() => remote.completeDelivery(any(), any())).thenAnswer((call) async {
      final id = call.positionalArguments[0] as int;
      mutationCalls++;
      active++;
      if (active > maximumActive) maximumActive = active;
      if (id == 1 && !started.isCompleted) {
        started.complete();
        await release.future;
      }
      active--;
      return ApiSuccessResult(_response(id));
    });

    final drain = manager.processQueue();
    await started.future;
    final retry = manager.retryAction(second.clientActionId);
    release.complete();
    await drain;

    expect(await retry, isFalse);
    expect(mutationCalls, 2);
    expect(maximumActive, 1);
  });
}
