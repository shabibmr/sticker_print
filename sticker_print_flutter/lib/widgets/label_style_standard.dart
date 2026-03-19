import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/certificate.dart';

class LabelStyleStandard extends pw.StatelessWidget {
  final Certificate certificate;
  final bool showBorder;
  final double labelWidth;
  final double labelHeight;
  final double borderInset;
  final double contentPadding;
  final double fontSize;
  final double lineGap;

  LabelStyleStandard({
    required this.certificate,
    this.showBorder = true,
    required this.labelWidth,
    required this.labelHeight,
    this.borderInset = 0.0,
    this.contentPadding = 1.0,
    this.fontSize = 8.0,
    this.lineGap = 1.0,
  });

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      width: labelWidth * PdfPageFormat.mm,
      height: labelHeight * PdfPageFormat.mm,
      padding: pw.EdgeInsets.all(borderInset),
      child: pw.Container(
        decoration: showBorder
            ? pw.BoxDecoration(border: pw.Border.all(width: 0.5))
            : null,
        padding: pw.EdgeInsets.all(contentPadding),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Serial Number
            if (certificate.serial.isNotEmpty)
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: lineGap / 2),
                child: pw.Text(
                  'S/N: ${certificate.serial}',
                  style: pw.TextStyle(
                    fontSize: fontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

            // Certificate Number
            if (certificate.certNo.isNotEmpty)
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: lineGap / 2),
                child: pw.Text(
                  'Cert: ${certificate.certNo}',
                  style: pw.TextStyle(fontSize: fontSize),
                ),
              ),

            pw.Spacer(),

            // Dates
            if (certificate.formattedIssueDate.isNotEmpty)
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: lineGap / 2),
                child: pw.Text(
                  'Issued: ${certificate.formattedIssueDate}',
                  style: pw.TextStyle(fontSize: fontSize - 1),
                ),
              ),
            if (certificate.formattedExpiryDate.isNotEmpty)
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: lineGap / 2),
                child: pw.Text(
                  'Expiry: ${certificate.formattedExpiryDate}',
                  style: pw.TextStyle(fontSize: fontSize - 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
