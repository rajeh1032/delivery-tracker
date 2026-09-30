import 'package:equatable/equatable.dart';

/// State of network connectivity for reactive UI elements.
class ConnectivityState extends Equatable {
  final bool isOnline;
  final bool justCameOnline;

  const ConnectivityState({
    required this.isOnline,
    this.justCameOnline = false,
  });

  const ConnectivityState.initial()
      : isOnline = true,
        justCameOnline = false;

  ConnectivityState copyWith({
    bool? isOnline,
    bool? justCameOnline,
  }) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      justCameOnline: justCameOnline ?? this.justCameOnline,
    );
  }

  @override
  List<Object?> get props => [isOnline, justCameOnline];
}
