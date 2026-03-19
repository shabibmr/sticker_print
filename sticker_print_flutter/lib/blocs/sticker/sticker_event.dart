import 'package:equatable/equatable.dart';
import '../../models/certificate.dart';

abstract class StickerEvent extends Equatable {
  const StickerEvent();

  @override
  List<Object> get props => [];
}

class SearchCertificates extends StickerEvent {
  final String query;

  const SearchCertificates(this.query);

  @override
  List<Object> get props => [query];
}

class SelectCertificate extends StickerEvent {
  final Certificate certificate;

  const SelectCertificate(this.certificate);

  @override
  List<Object> get props => [certificate];
}

class UpdateLabelConfig extends StickerEvent {
  final double? width;
  final double? height;
  final String? style;
  final double? fontSize;
  final bool? showBorder;
  final double? borderInset;
  final double? contentPadding;
  final double? lineGap;
  final double? style3HeaderFontMm;
  final double? style3SubHeaderFontMm;
  final double? style3FieldFontMm;
  final double? style3FooterFontMm;

  const UpdateLabelConfig({
    this.width,
    this.height,
    this.style,
    this.fontSize,
    this.showBorder,
    this.borderInset,
    this.contentPadding,
    this.lineGap,
    this.style3HeaderFontMm,
    this.style3SubHeaderFontMm,
    this.style3FieldFontMm,
    this.style3FooterFontMm,
  });

  @override
  List<Object> get props => [
    width ?? '',
    height ?? '',
    style ?? '',
    fontSize ?? '',
    showBorder ?? '',
    borderInset ?? '',
    contentPadding ?? '',
    lineGap ?? '',
    style3HeaderFontMm ?? '',
    style3SubHeaderFontMm ?? '',
    style3FieldFontMm ?? '',
    style3FooterFontMm ?? '',
  ];
}
