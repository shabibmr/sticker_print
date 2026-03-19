import 'package:equatable/equatable.dart';

enum ConnectivityStatus { initial, connecting, connected, disconnected, error }

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;
  final String? errorMessage;
  final int? uid;

  const ConnectivityState({
    this.status = ConnectivityStatus.initial,
    this.errorMessage,
    this.uid,
  });

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    String? errorMessage,
    int? uid,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      uid: uid ?? this.uid,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, uid];
}
