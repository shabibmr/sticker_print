import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final bool isConfigured;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.isConfigured = false,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    bool? isConfigured,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      isConfigured: isConfigured ?? this.isConfigured,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isConfigured, errorMessage];
}
