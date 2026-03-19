import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../repositories/settings_repository.dart';
import '../../services/odoo_client.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(const SettingsState()) {
    print('DEBUG: SettingsBloc Initialized');
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
    on<ResetSettings>(_onResetSettings);
    on<TestConnection>(_onTestConnection);
    on<LoadPrinters>(_onLoadPrinters);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final config = await _settingsRepository.loadSettings();
      // Load printers when settings are loaded
      add(LoadPrinters());
      emit(state.copyWith(status: SettingsStatus.loaded, config: config));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _settingsRepository.saveSettings(event.config);
      emit(state.copyWith(status: SettingsStatus.loaded, config: event.config));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _settingsRepository.resetSettings();
      final config = await _settingsRepository.loadSettings();
      emit(state.copyWith(status: SettingsStatus.loaded, config: config));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTestConnection(
    TestConnection event,
    Emitter<SettingsState> emit,
  ) async {
    emit(
      state.copyWith(
        connectionStatus: ConnectionStatus.testing,
        connectionMessage: 'Testing connection...',
      ),
    );
    try {
      final client = OdooClient(event.config);
      final uid = await client.authenticate();
      emit(
        state.copyWith(
          connectionStatus: ConnectionStatus.success,
          connectionMessage: '✅ Connection successful! User ID: $uid',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          connectionStatus: ConnectionStatus.failure,
          connectionMessage: '❌ Connection failed: $e',
        ),
      );
    }
  }

  Future<void> _onLoadPrinters(
    LoadPrinters event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoadingPrinters: true));
    try {
      final printers = await Printing.listPrinters();
      emit(state.copyWith(isLoadingPrinters: false, printers: printers));
    } catch (e) {
      emit(state.copyWith(isLoadingPrinters: false));
    }
  }
}
