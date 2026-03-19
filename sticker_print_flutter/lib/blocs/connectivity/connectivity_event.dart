import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class CheckConnectivity extends ConnectivityEvent {}

class Disconnect extends ConnectivityEvent {}
