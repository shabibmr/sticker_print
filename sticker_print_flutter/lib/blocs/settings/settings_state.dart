import 'package:equatable/equatable.dart';
import 'package:printing/printing.dart';
import '../../models/app_config.dart';

enum SettingsStatus { initial, loading, loaded, error }

enum ConnectionStatus { initial, testing, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final AppConfig config;
  final String? errorMessage;

  // Connection Test
  final ConnectionStatus connectionStatus;
  final String? connectionMessage;

  // Printers
  final List<Printer> printers;
  final bool isLoadingPrinters;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.config = const AppConfig(),
    this.errorMessage,
    this.connectionStatus = ConnectionStatus.initial,
    this.connectionMessage,
    this.printers = const [],
    this.isLoadingPrinters = false,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    AppConfig? config,
    String? errorMessage,
    ConnectionStatus? connectionStatus,
    String? connectionMessage,
    List<Printer>? printers,
    bool? isLoadingPrinters,
  }) {
    return SettingsState(
      status: status ?? this.status,
      config: config ?? this.config,
      errorMessage: errorMessage,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      connectionMessage: connectionMessage ?? this.connectionMessage,
      printers: printers ?? this.printers,
      isLoadingPrinters: isLoadingPrinters ?? this.isLoadingPrinters,
    );
  }

  @override
  List<Object?> get props => [
    status,
    config,
    errorMessage,
    connectionStatus,
    connectionMessage,
    printers,
    isLoadingPrinters,
  ];
}
