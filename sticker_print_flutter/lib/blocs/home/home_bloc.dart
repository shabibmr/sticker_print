import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../settings/settings_bloc.dart';
import '../settings/settings_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SettingsBloc _settingsBloc;
  late StreamSubscription<SettingsState> _settingsSubscription;

  HomeBloc({required SettingsBloc settingsBloc})
    : _settingsBloc = settingsBloc,
      super(const HomeState()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeSettingsRefreshed>(_onHomeSettingsRefreshed);

    _settingsSubscription = _settingsBloc.stream.listen((settingsState) {
      add(HomeSettingsRefreshed());
    });
  }

  void _onHomeStarted(HomeStarted event, Emitter<HomeState> emit) {
    // Initial check
    final isConfigured = _settingsBloc.state.config.isValid;
    emit(
      state.copyWith(status: HomeStatus.success, isConfigured: isConfigured),
    );
  }

  void _onHomeSettingsRefreshed(
    HomeSettingsRefreshed event,
    Emitter<HomeState> emit,
  ) {
    final isConfigured = _settingsBloc.state.config.isValid;
    emit(
      state.copyWith(status: HomeStatus.success, isConfigured: isConfigured),
    );
  }

  @override
  Future<void> close() {
    _settingsSubscription.cancel();
    return super.close();
  }
}
