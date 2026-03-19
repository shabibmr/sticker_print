import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/certificate.dart';

/// LabelStyle3 — same layout as LabelStyle1 ("Tested") but with independent
/// font sizes for each text line, controllable from the preview panel.
class LabelStyle3 extends pw.StatelessWidget {
  final Certificate certificate;
  final bool isPreview;
  final pw.ImageProvider? logoImage;
  final double labelWidth;
  final double labelHeight;

  /// Font sizes in mm — converted to PDF points internally.
  final double headerFontSizeMm;
  final double subHeaderFontSizeMm;
  final double fieldFontSizeMm;
  final double footerFontSizeMm;

  LabelStyle3({
    required this.certificate,
    this.isPreview = false,
    this.logoImage,
    required this.labelWidth,
    required this.labelHeight,
    this.headerFontSizeMm = 2.0,
    this.subHeaderFontSizeMm = 2.0,
    this.fieldFontSizeMm = 2.0,
    this.footerFontSizeMm = 1.2,
  });

  @override
  pw.Widget build(pw.Context context) {
    final double w = labelWidth * PdfPageFormat.mm;
    final double h = labelHeight * PdfPageFormat.mm;

    final bool is18mm = (labelHeight - 18).abs() < 1.0;

    // Logo size based on label height
    final double logoSizeMm = is18mm ? 3.0 : 5.0;
    final double logoSize = logoSizeMm * PdfPageFormat.mm;

    // Convert per-line font sizes from mm to PDF points
    final double headerFontSize = headerFontSizeMm * PdfPageFormat.mm;
    final double subHeaderFontSize = subHeaderFontSizeMm * PdfPageFormat.mm;
    final double fieldFontSize = fieldFontSizeMm * PdfPageFormat.mm;
    final double footerFontSize = footerFontSizeMm * PdfPageFormat.mm;

    final double borderWidth = 0.5;
    final double paddingMm = is18mm ? 0.5 : 1.5;
    final double padding = paddingMm * PdfPageFormat.mm;

    return pw.Container(
      width: w,
      height: h,
      padding: pw.EdgeInsets.all(padding),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          // Header: Logo + Title
          pw.Row(
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
                    pw.Text(
                      'DIME MARINE SERVICES',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: headerFontSize,
                        decoration: pw.TextDecoration.underline,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                    pw.Text(
                      'TESTED',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: subHeaderFontSize,
                        decoration: pw.TextDecoration.underline,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: (is18mm ? 1.0 : 2.0) * PdfPageFormat.mm),

          // Data rows in bordered box
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: borderWidth),
            ),
            padding: pw.EdgeInsets.symmetric(
              horizontal: 1.5 * PdfPageFormat.mm,
              vertical: 0.5 * PdfPageFormat.mm,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildRow('S/N', certificate.serial, fieldFontSize, is18mm),
                pw.SizedBox(height: (is18mm ? 0.2 : 1.2) * PdfPageFormat.mm),
                _buildRow(
                  'Test Date',
                  certificate.formattedTestedDate,
                  fieldFontSize,
                  is18mm,
                ),
                pw.SizedBox(height: (is18mm ? 0.2 : 1.2) * PdfPageFormat.mm),
                _buildRow(
                  'Due Date',
                  certificate.formattedExpiryDate,
                  fieldFontSize,
                  is18mm,
                ),
                pw.SizedBox(height: (is18mm ? 0.2 : 1.2) * PdfPageFormat.mm),
                _buildRow(
                  'Cert.No',
                  certificate.shortCertNo,
                  fieldFontSize,
                  is18mm,
                ),
              ],
            ),
          ),

          pw.Spacer(),

          // Footer
          pw.Text(
            'www.dimemarine.com,Mb:+97430973432',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.normal,
              fontSize: footerFontSize,
            ),
          ),

          pw.SizedBox(height: 1.0 * PdfPageFormat.mm),
        ],
      ),
    );
  }

  pw.Widget _buildRow(
    String label,
    String value,
    double fontSize,
    bool is18mm,
  ) {
    final double labelWidthMm = is18mm ? 12 : 18;
    return pw.Row(
      children: [
        pw.SizedBox(
          width: labelWidthMm * PdfPageFormat.mm,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
        pw.Text(
          ' : ',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
