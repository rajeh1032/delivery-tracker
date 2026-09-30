import 'dart:async';
import 'package:injectable/injectable.dart';

import '../../features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import '../../features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import '../../features/delivery/domain/entities/delivery_action.dart';
import 'connectivity_service.dart';
import 'delivery_action_syncer.dart';
import 'proof_storage_service.dart';
import 'sync_retry_policy.dart';

@lazySingleton
class SyncManager {
  final DeliveryLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  late final DeliveryActionSyncer _actionSyncer;
  final SyncRetryPolicy _retryPolicy;
  Timer? _retryTimer;
  bool _disposed = false;

  bool _isSyncing = false;
  Future<void> _lockTail = Future<void>.value();
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _debounceTimer;

  SyncManager(
    DeliveryLocalDataSource localDataSource,
    DeliveryRemoteDs remoteDataSource,
    this._connectivityService,
    ProofStorageService proofStorageService, {
    @ignoreParam SyncRetryPolicy? retryPolicy,
  }) : _localDataSource = localDataSource,
       _retryPolicy = retryPolicy ?? SyncRetryPolicy() {
    _actionSyncer = DeliveryActionSyncer(
      localDataSource,
      remoteDataSource,
      proofStorageService,
      _retryPolicy,
    );
  }

  bool get isSyncing => _isSyncing;

  void startListening({Duration debounce = const Duration(seconds: 5)}) {
    _disposed = false;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((isConnected) {
          if (isConnected) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(debounce, () {
              processQueue();
            });
          }
        });
    unawaited(processQueue());
  }

  Future<void> processQueue() async {
    await _withLock(() async {
      if (_disposed) return;
      _isSyncing = true;
      try {
        if (!await _connectivityService.checkReachability()) return;
        final pendingActions = await _localDataSource.getPendingActions();
        for (final action in pendingActions) {
          if (_disposed) break;
          if (_retryPolicy.canAttempt(action)) {
            await _syncActionUnlocked(action);
          }
        }
        await _scheduleRetry();
      } finally {
        _isSyncing = false;
      }
    });
  }

  Future<bool> syncAction(DeliveryAction action) async {
    return _withLock(() async {
      if (_disposed) return false;
      final queued = await _queuedAction(action.clientActionId);
      if (queued == null || !_retryPolicy.canAttempt(queued)) return false;
      if (!await _connectivityService.checkReachability()) return false;
      return _syncActionUnlocked(queued);
    });
  }

  Future<bool> _syncActionUnlocked(DeliveryAction action) async {
    final success = await _actionSyncer.sync(action);
    await _scheduleRetry();
    return success;
  }

  Future<bool> retryAction(String clientActionId) async {
    return _withLock(() async {
      if (_disposed) return false;
      final action = await _queuedAction(clientActionId);
      if (action == null || !action.autoRetryAllowed) return false;
      if (action.nextRetryAt?.isAfter(_retryPolicy.now()) ?? false) {
        return false;
      }
      if (!await _connectivityService.checkReachability()) return false;
      final reset = action.isFailed
          ? action.copyWith(retryCount: 0, clearNextRetryAt: true)
          : action;
      if (action.isFailed) await _localDataSource.savePendingAction(reset);
      return _syncActionUnlocked(reset);
    });
  }

  Future<DeliveryAction?> _queuedAction(String clientActionId) async {
    for (final action in await _localDataSource.getPendingActions()) {
      if (action.clientActionId == clientActionId) return action;
    }
    return null;
  }

  Future<void> _scheduleRetry() async {
    _retryTimer?.cancel();
    if (_disposed) return;
    final earliest = _retryPolicy.nextDeadline(
      await _localDataSource.getPendingActions(),
    );
    if (_disposed || earliest == null) return;
    final delay = earliest.difference(_retryPolicy.now());
    _retryTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      unawaited(processQueue());
    });
  }

  Future<T> _withLock<T>(Future<T> Function() action) async {
    final previous = _lockTail;
    final release = Completer<void>();
    _lockTail = release.future;
    await previous;
    try {
      return await action();
    } finally {
      release.complete();
    }
  }

  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}
