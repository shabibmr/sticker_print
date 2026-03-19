import 'package:flutter_bloc/flutter_bloc.dart';
import 'sticker_event.dart';
import 'sticker_state.dart';
import '../../repositories/odoo_repository.dart';
import '../../models/app_config.dart';

class StickerBloc extends Bloc<StickerEvent, StickerState> {
  final OdooRepository _odooRepository;

  StickerBloc({
    required OdooRepository odooRepository,
    required AppConfig initialConfig,
  }) : _odooRepository = odooRepository,
       super(
         StickerState(
           labelWidth: initialConfig.labelWidth,
           labelHeight: initialConfig.labelHeight,
           labelStyle: initialConfig.labelStyle,
         ),
       ) {
    on<SearchCertificates>(_onSearchCertificates);
    on<SelectCertificate>(_onSelectCertificate);
    on<UpdateLabelConfig>(_onUpdateLabelConfig);

    // Initialize repository with config
    _odooRepository.initialize(initialConfig);

    // Initial load
    add(const SearchCertificates(''));
  }

  Future<void> _onSearchCertificates(
    SearchCertificates event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerStatus.loading));
    try {
      final certs = await _odooRepository.searchCertificates(
        searchTerm: event.query,
      );
      emit(state.copyWith(status: StickerStatus.success, certificates: certs));
    } catch (e) {
      emit(
        state.copyWith(status: StickerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSelectCertificate(
    SelectCertificate event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetails: true));
    try {
      final fullCert = await _odooRepository.getCertificateDetails(
        event.certificate.id,
      );
      emit(
        state.copyWith(selectedCertificate: fullCert, isLoadingDetails: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingDetails: false,
          errorMessage: 'Failed to load details: $e',
        ),
      );
    }
  }

  void _onUpdateLabelConfig(
    UpdateLabelConfig event,
    Emitter<StickerState> emit,
  ) {
    emit(
      state.copyWith(
        labelWidth: event.width,
        labelHeight: event.height,
        labelStyle: event.style,
        fontSize: event.fontSize,
        showBorder: event.showBorder,
        borderInset: event.borderInset,
        contentPadding: event.contentPadding,
        lineGap: event.lineGap,
      ),
    );
  }

  @override
  void onChange(Change<StickerState> change) {
    super.onChange(change);
    print('DEBUG: StickerBloc Change - Status: ${change.nextState.status}');
    print(
      'DEBUG: StickerBloc Config - Size: ${change.nextState.labelWidth}x${change.nextState.labelHeight}',
    );
  }
}
