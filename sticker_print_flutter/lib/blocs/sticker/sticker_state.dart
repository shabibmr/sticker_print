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

  // Per-line font sizes for style_3 (in mm)
  final double style3HeaderFontMm;
  final double style3SubHeaderFontMm;
  final double style3FieldFontMm;
  final double style3FooterFontMm;

  const StickerState({
    this.status = StickerStatus.initial,
    this.certificates = const [],
    this.selectedCertificate,
    this.errorMessage,
    this.labelWidth = 30.0,
    this.labelHeight = 18.0,
    this.labelStyle = 'style_1',
    this.fontSize = 8.0,
    this.showBorder = true,
    this.borderInset = 0.0,
    this.contentPadding = 1.0,
    this.lineGap = 1.0,
    this.isLoadingDetails = false,
    this.style3HeaderFontMm = 2.0,
    this.style3SubHeaderFontMm = 2.0,
    this.style3FieldFontMm = 2.0,
    this.style3FooterFontMm = 1.2,
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
    double? style3HeaderFontMm,
    double? style3SubHeaderFontMm,
    double? style3FieldFontMm,
    double? style3FooterFontMm,
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
      style3HeaderFontMm: style3HeaderFontMm ?? this.style3HeaderFontMm,
      style3SubHeaderFontMm:
          style3SubHeaderFontMm ?? this.style3SubHeaderFontMm,
      style3FieldFontMm: style3FieldFontMm ?? this.style3FieldFontMm,
      style3FooterFontMm: style3FooterFontMm ?? this.style3FooterFontMm,
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
    style3HeaderFontMm,
    style3SubHeaderFontMm,
    style3FieldFontMm,
    style3FooterFontMm,
  ];
}
