import 'package:equatable/equatable.dart';
import '../../models/app_config.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final AppConfig config;

  const UpdateSettings(this.config);

  @override
  List<Object> get props => [config];
}

class ResetSettings extends SettingsEvent {}

class TestConnection extends SettingsEvent {
  final AppConfig config;

  const TestConnection(this.config);

  @override
  List<Object> get props => [config];
}

class LoadPrinters extends SettingsEvent {}
