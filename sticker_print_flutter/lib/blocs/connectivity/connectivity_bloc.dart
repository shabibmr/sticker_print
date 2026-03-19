import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/odoo_repository.dart';
import 'connectivity_event.dart';
import 'connectivity_state.dart';
import '../settings/settings_bloc.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final OdooRepository _odooRepository;
  final SettingsBloc _settingsBloc;

  ConnectivityBloc({
    required OdooRepository odooRepository,
    required SettingsBloc settingsBloc,
  }) : _odooRepository = odooRepository,
       _settingsBloc = settingsBloc,
       super(const ConnectivityState()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    on<Disconnect>(_onDisconnect);

    // Automatically check connection if config is valid on startup
    if (_settingsBloc.state.config.isValid) {
      add(CheckConnectivity());
    }
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivity event,
    Emitter<ConnectivityState> emit,
  ) async {
    final config = _settingsBloc.state.config;
    if (!config.isValid) {
      emit(
        state.copyWith(
          status: ConnectivityStatus.disconnected,
          errorMessage: 'Configuration incomplete',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ConnectivityStatus.connecting));

    try {
      // Ensure repository is initialized with current config
      _odooRepository.initialize(config);

      final uid = await _odooRepository.authenticate();
      emit(state.copyWith(status: ConnectivityStatus.connected, uid: uid));
    } catch (e) {
      emit(
        state.copyWith(
          status: ConnectivityStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onDisconnect(Disconnect event, Emitter<ConnectivityState> emit) {
    emit(const ConnectivityState(status: ConnectivityStatus.disconnected));
  }
}
