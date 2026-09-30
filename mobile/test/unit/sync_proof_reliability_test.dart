import 'dart:io';

import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/failures.dart';
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
import 'sync_test_fixtures.dart';

class _Local extends Mock implements DeliveryLocalDataSource {}

class _Remote extends Mock implements DeliveryRemoteDs {}

class _Connectivity extends Mock implements ConnectivityService {}

class _Proofs extends Mock implements ProofStorageService {}

void main() {
  late _Local local;
  late _Remote remote;
  late _Connectivity connectivity;
  late _Proofs proofs;
  late SyncManager manager;
  late Directory dir;
  late File photo;
  late DeliveryAction action;
  var queued = <DeliveryAction>[];
  var delivery = DeliveryEntity(
    id: 4,
    orderNumber: 'ORD-4',
    customerName: 'Sam',
    phone: '555',
    address: 'Town',
    amountDue: 10,
    status: DeliveryStatus.delivered,
    syncStatus: SyncStatus.waitingToSync,
  );

  setUpAll(() {
    registerFallbackValue(delivery);
    registerFallbackValue(
      DeliveryAction(
        clientActionId: 'fallback',
        deliveryId: 4,
        type: DeliveryActionType.complete,
        payload: const {},
        createdAt: DateTime.utc(2026),
      ),
    );
    registerFallbackValue(
      const CompleteDeliveryRequestDto(
        recipientName: 'Sam',
        clientActionId: 'fallback',
      ),
    );
    registerFallbackValue(File('fallback.jpg'));
  });
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('sync_proof_');
    photo = File('${dir.path}/proof.jpg')..writeAsStringSync('proof');
    action = DeliveryAction(
      clientActionId: 'stable-action-id',
      deliveryId: 4,
      type: DeliveryActionType.complete,
      payload: {
        NetworkConstants.keyRecipientName: 'Sam',
        NetworkConstants.keyLocalPhotoPath: photo.path,
      },
      createdAt: DateTime.utc(2026),
    );
    queued = [action];
    delivery = delivery.copyWith(syncStatus: SyncStatus.waitingToSync);
    local = _Local();
    remote = _Remote();
    connectivity = _Connectivity();
    proofs = _Proofs();
    manager = SyncManager(local, remote, connectivity, proofs);
    when(() => connectivity.checkReachability()).thenAnswer((_) async => true);
    when(() => local.getPendingActions()).thenAnswer((_) async => [...queued]);
    when(() => local.getDeliveryById(4)).thenAnswer((_) async => delivery);
    when(() => local.updateDelivery(any())).thenAnswer((call) async {
      delivery = call.positionalArguments.single as DeliveryEntity;
    });
    when(() => local.savePendingAction(any())).thenAnswer((call) async {
      queued = [call.positionalArguments.single as DeliveryAction];
    });
    when(() => local.deletePendingAction(any())).thenAnswer((_) async {
      final id = queued.first.clientActionId;
      queued.removeWhere((pending) => pending.clientActionId == id);
    });
    when(() => proofs.getProofFile(photo.path)).thenReturn(photo);
    when(() => proofs.deleteProofFile(photo.path)).thenAnswer((_) async {});
  });
  tearDown(() async {
    manager.dispose();
    await dir.delete(recursive: true);
  });

  test('failed proof upload keeps file and action for same-ID retry', () async {
    when(() => remote.uploadProof(4, photo)).thenAnswer(
      (_) async => const ApiErrorResult(
        'Upload failed',
        statusCode: 500,
        failure: TransientFailure(errorMessage: 'Upload failed'),
      ),
    );
    when(
      () => remote.completeDelivery(4, any()),
    ).thenAnswer((_) async => ApiSuccessResult(syncSuccess(4)));

    await manager.processQueue();
    expect(queued.single.status, SyncStatus.failed);
    expect(queued.single.clientActionId, action.clientActionId);
    expect(photo.existsSync(), isTrue);
    verifyNever(() => remote.completeDelivery(4, any()));
    verifyNever(() => proofs.deleteProofFile(photo.path));

    when(() => remote.uploadProof(4, photo)).thenAnswer(
      (_) async => ApiSuccessResult(
        ProofUploadResponseDto(message: 'ok', proofUrl: '/proof'),
      ),
    );
    expect(await manager.retryAction(action.clientActionId), isTrue);
    expect(queued, isEmpty);
    verify(
      () => remote.completeDelivery(
        4,
        any(
          that: predicate(
            (dto) =>
                (dto as CompleteDeliveryRequestDto).clientActionId ==
                action.clientActionId,
          ),
        ),
      ),
    ).called(1);
    verify(() => proofs.deleteProofFile(photo.path)).called(1);
  });

  test(
    'missing referenced proof fails without submitting completion',
    () async {
      when(() => proofs.getProofFile(photo.path)).thenReturn(null);
      when(
        () => remote.completeDelivery(4, any()),
      ).thenAnswer((_) async => ApiSuccessResult(syncSuccess(4)));
      await manager.processQueue();

      expect(queued.single.status, SyncStatus.failed);
      expect(queued.single.clientActionId, action.clientActionId);
      verifyNever(() => remote.completeDelivery(4, any()));
    },
  );

  test('action without a photo completes normally', () async {
    action = action.copyWith(payload: const {'recipient_name': 'Sam'});
    queued = [action];
    when(
      () => remote.completeDelivery(4, any()),
    ).thenAnswer((_) async => ApiSuccessResult(syncSuccess(4)));

    await manager.processQueue();
    expect(queued, isEmpty);
    verifyNever(() => remote.uploadProof(any(), any()));
  });

  test('proof cleanup failure does not stop later queued actions', () async {
    final next = action.copyWith(
      clientActionId: 'next-action',
      payload: const {NetworkConstants.keyRecipientName: 'Sam'},
    );
    queued = [action, next];
    when(() => remote.uploadProof(4, photo)).thenAnswer(
      (_) async => ApiSuccessResult(
        ProofUploadResponseDto(message: 'ok', proofUrl: '/p'),
      ),
    );
    when(
      () => remote.completeDelivery(4, any()),
    ).thenAnswer((_) async => ApiSuccessResult(syncSuccess(4)));
    when(
      () => proofs.deleteProofFile(photo.path),
    ).thenThrow(FileSystemException('busy', photo.path));

    await manager.processQueue();

    expect(queued, isEmpty);
    verify(() => remote.completeDelivery(4, any())).called(2);
  });
}
