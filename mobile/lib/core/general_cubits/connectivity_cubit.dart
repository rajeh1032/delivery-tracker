import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../services/connectivity_service.dart';
import 'connectivity_state.dart';

/// Cubit managing real-time connectivity state for app-wide reactive banners.
@injectable
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit(this._connectivityService)
      : super(const ConnectivityState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final initialReachable = await _connectivityService.checkReachability();
    emit(ConnectivityState(isOnline: initialReachable));

    _subscription = _connectivityService.onConnectivityChanged.listen(
      (isConnected) {
        final wasOffline = !state.isOnline;
        final justCameOnline = wasOffline && isConnected;
        emit(ConnectivityState(
          isOnline: isConnected,
          justCameOnline: justCameOnline,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
