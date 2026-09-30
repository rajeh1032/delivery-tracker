import 'dart:async';
import 'package:injectable/injectable.dart';

import '../../features/delivery/data_sources/sources/local/delivery_local_ds.dart';
import '../../features/delivery/data_sources/sources/remote/delivery_remote_ds.dart';
import '../../features/delivery/domain/entities/delivery_action.dart';
import 'connectivity_service.dart';
import 'delivery_action_syncer.dart';
import 'proof_storage_service.dart';

@lazySingleton
class SyncManager {
  final DeliveryLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final DeliveryActionSyncer _actionSyncer;

  bool _isSyncing = false;
  Future<void> _lockTail = Future<void>.value();
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _debounceTimer;

  SyncManager(
    DeliveryLocalDataSource localDataSource,
    DeliveryRemoteDs remoteDataSource,
    this._connectivityService,
    ProofStorageService proofStorageService,
  ) : _localDataSource = localDataSource,
      _actionSyncer = DeliveryActionSyncer(
        localDataSource,
        remoteDataSource,
        proofStorageService,
      );

  bool get isSyncing => _isSyncing;

  void startListening({Duration debounce = const Duration(seconds: 5)}) {
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
  }

  Future<void> processQueue() async {
    await _withLock(() async {
      _isSyncing = true;
      try {
        if (!await _connectivityService.checkReachability()) return;
        final pendingActions = await _localDataSource.getPendingActions();
        for (final action in pendingActions) {
          await _syncActionUnlocked(action);
        }
      } finally {
        _isSyncing = false;
      }
    });
  }

  Future<bool> syncAction(DeliveryAction action) async {
    return _withLock(() async {
      final queued = await _queuedAction(action.clientActionId);
      if (queued == null) return false;
      if (!await _connectivityService.checkReachability()) return false;
      return _syncActionUnlocked(queued);
    });
  }

  Future<bool> _syncActionUnlocked(DeliveryAction action) async {
    return _actionSyncer.sync(action);
  }

  Future<bool> retryAction(String clientActionId) async {
    return _withLock(() async {
      final action = await _queuedAction(clientActionId);
      if (action == null) return false;
      if (!await _connectivityService.checkReachability()) return false;
      return _syncActionUnlocked(action);
    });
  }

  Future<DeliveryAction?> _queuedAction(String clientActionId) async {
    for (final action in await _localDataSource.getPendingActions()) {
      if (action.clientActionId == clientActionId) return action;
    }
    return null;
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
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}
