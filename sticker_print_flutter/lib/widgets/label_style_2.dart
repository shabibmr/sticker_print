import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/certificate.dart';

class LabelStyle2 extends pw.StatelessWidget {
  final Certificate certificate;
  final bool isPreview;
  final pw.ImageProvider? logoImage;
  final double labelWidth;
  final double labelHeight;
  final double fontSize;

  LabelStyle2({
    required this.certificate,
    this.isPreview = false,
    this.logoImage,
    required this.labelWidth,
    required this.labelHeight,
    this.fontSize = 13,
  });

  @override
  pw.Widget build(pw.Context context) {
    final double w = labelWidth * PdfPageFormat.mm;
    final double h = labelHeight * PdfPageFormat.mm;

    // Detect if this is the 18mm height label (allowing slight float tolerance)
    final bool is18mm = (labelHeight - 18).abs() < 1.0;

    // Sizes tuned for physical sticker dimensions
    double logoSizeMm = is18mm ? 4.0 : 5.0;
    double headerTextSizeMm = is18mm ? 1.8 : 2.0;    // ~5.1pt / ~5.7pt
    double subHeaderTextSizeMm = is18mm ? 1.8 : 2.0; // ~5.1pt / ~5.7pt
    double fieldTextSizeMm = is18mm ? 1.8 : 2.0;     // ~5.1pt / ~5.7pt
    double footerFontSizeMm = is18mm ? 1.3 : 1.2;    // ~3.7pt / ~3.4pt

    // Convert mm to PDF points
    final double logoSize = logoSizeMm * PdfPageFormat.mm;
    final double headerFontSize = headerTextSizeMm * PdfPageFormat.mm;
    final double subHeaderFontSize = subHeaderTextSizeMm * PdfPageFormat.mm;
    final double fieldFontSize = fieldTextSizeMm * PdfPageFormat.mm;
    final double footerFontSize = footerFontSizeMm * PdfPageFormat.mm;

    final double borderWidth = 0.25;
    final double paddingMm = is18mm ? 0.5 : 1.5;
    final double padding = paddingMm * PdfPageFormat.mm;

    final hPad = pw.EdgeInsets.symmetric(horizontal: padding);

    final double outerMargin = 1.0 * PdfPageFormat.mm;

    return pw.Container(
      width: w,
      height: h,
      padding: pw.EdgeInsets.all(outerMargin),
      child: pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.75)),
        child: pw.FittedBox(
          fit: pw.BoxFit.scaleDown,
          alignment: pw.Alignment.topCenter,
          child: pw.SizedBox(
            width: w - 2 * outerMargin - 1.5 + 2, // +2pt forces FittedBox scale-down
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // Header: Logo + Title
                pw.Padding(
                  padding: hPad,
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Logo
                      pw.Container(
                        width: logoSize * 1.5,
                        height: logoSize,
                        alignment: pw.Alignment.center,
                        child: logoImage != null
                            ? pw.Image(logoImage!)
                            : pw.Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(width: 0.5),
                                  shape: pw.BoxShape.circle,
                                ),
                                child: pw.Center(
                                  child: pw.Text(
                                    'D',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: logoSize * 0.6,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      pw.SizedBox(width: 2 * PdfPageFormat.mm),
                      // Title
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(
                                'DIME MARINE SERVICES',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: headerFontSize,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            if (!is18mm) pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                            pw.Text(
                              'CALIBRATED',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: subHeaderFontSize,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (!is18mm) pw.SizedBox(height: 2.0 * PdfPageFormat.mm),

                // Data rows — lines extend full width, row text is padded
                _buildPaddedRow('S/N', certificate.serial, fieldFontSize, is18mm, hPad),
                pw.Container(height: borderWidth, color: PdfColors.black),
                _buildPaddedRow('Cali Date', certificate.formattedIssueDate, fieldFontSize, is18mm, hPad),
                pw.Container(height: borderWidth, color: PdfColors.black),
                _buildPaddedRow('Due Date', certificate.formattedExpiryDate, fieldFontSize, is18mm, hPad),
                pw.Container(height: borderWidth, color: PdfColors.black),
                _buildPaddedRow('Cert.No', certificate.shortCertNo, fieldFontSize, is18mm, hPad),
                pw.Container(height: borderWidth, color: PdfColors.black),

                // Footer
                pw.Padding(
                  padding: hPad,
                  child: pw.Text(
                    'www.dimemarine.com,Mb:+97430973432',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.normal,
                      fontSize: footerFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildPaddedRow(
    String label,
    String value,
    double fieldFontSize,
    bool is18mm,
    pw.EdgeInsets hPad,
  ) {
    final double labelWidthMm = is18mm ? 12 : 18;
    return pw.Padding(
      padding: hPad,
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: labelWidthMm * PdfPageFormat.mm,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: fieldFontSize,
              ),
            ),
          ),
          pw.Text(
            ' : ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: fieldFontSize,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: fieldFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
