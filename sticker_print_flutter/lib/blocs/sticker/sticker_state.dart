import 'package:equatable/equatable.dart';
import '../../models/certificate.dart';

enum StickerStatus { initial, loading, success, error }

class StickerState extends Equatable {
  final StickerStatus status;
  final List<Certificate> certificates;
  final Certificate? selectedCertificate;
  final String? errorMessage;

  // Label Configuration
  final double labelWidth;
  final double labelHeight;
  final String labelStyle;
  final double fontSize;
  final bool showBorder;
  final double borderInset;
  final double contentPadding;
  final double lineGap;
  final bool isLoadingDetails;

  const StickerState({
    this.status = StickerStatus.initial,
    this.certificates = const [],
    this.selectedCertificate,
    this.errorMessage,
    this.labelWidth = 101.6,
    this.labelHeight = 50.8,
    this.labelStyle = 'standard',
    this.fontSize = 8.0,
    this.showBorder = true,
    this.borderInset = 0.0,
    this.contentPadding = 1.0,
    this.lineGap = 1.0,
    this.isLoadingDetails = false,
  });

  StickerState copyWith({
    StickerStatus? status,
    List<Certificate>? certificates,
    Certificate? selectedCertificate,
    String? errorMessage,
    double? labelWidth,
    double? labelHeight,
    String? labelStyle,
    double? fontSize,
    bool? showBorder,
    double? borderInset,
    double? contentPadding,
    double? lineGap,
    bool? isLoadingDetails,
  }) {
    return StickerState(
      status: status ?? this.status,
      certificates: certificates ?? this.certificates,
      selectedCertificate: selectedCertificate ?? this.selectedCertificate,
      errorMessage: errorMessage,
      labelWidth: labelWidth ?? this.labelWidth,
      labelHeight: labelHeight ?? this.labelHeight,
      labelStyle: labelStyle ?? this.labelStyle,
      fontSize: fontSize ?? this.fontSize,
      showBorder: showBorder ?? this.showBorder,
      borderInset: borderInset ?? this.borderInset,
      contentPadding: contentPadding ?? this.contentPadding,
      lineGap: lineGap ?? this.lineGap,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
    );
  }

  @override
  List<Object?> get props => [
    status,
    certificates,
    selectedCertificate,
    errorMessage,
    labelWidth,
    labelHeight,
    labelStyle,
    fontSize,
    showBorder,
    borderInset,
    contentPadding,
    lineGap,
    isLoadingDetails,
  ];
}
