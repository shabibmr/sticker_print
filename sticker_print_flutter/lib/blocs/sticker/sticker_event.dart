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

  const UpdateLabelConfig({
    this.width,
    this.height,
    this.style,
    this.fontSize,
    this.showBorder,
    this.borderInset,
    this.contentPadding,
    this.lineGap,
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
  ];
}
