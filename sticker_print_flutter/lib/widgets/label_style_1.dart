import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/certificate.dart';

class LabelStyle1 extends pw.StatelessWidget {
  final Certificate certificate;
  final bool isPreview;
  final pw.ImageProvider? logoImage;
  final double labelWidth;
  final double labelHeight;

  LabelStyle1({
    required this.certificate,
    this.isPreview = false,
    this.logoImage,
    required this.labelWidth,
    required this.labelHeight,
  });

  @override
  pw.Widget build(pw.Context context) {
    // Yellow background color for preview
    // const PdfColor yellowColor = PdfColor.fromInt(0xFFFFEB3B);
    // The image used a slightly more amber/orange yellow
    const PdfColor yellowColor = PdfColor.fromInt(0xFFFFD700);

    final double scale = labelHeight / 24.0;

    return pw.Container(
      decoration: isPreview
          ? pw.BoxDecoration(color: yellowColor)
          : null, // Transparent/White for print
      padding: pw.EdgeInsets.all(4 * scale),
      child: pw.Column(
        children: [
          // Header Section
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              pw.Container(
                width: 60 * scale,
                height: 40 * scale,
                alignment: pw.Alignment.center,
                child: logoImage != null
                    ? pw.Image(logoImage!)
                    : pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 20 * scale,
                            height: 20 * scale,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 1 * scale),
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'D',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10 * scale,
                                ),
                              ),
                            ),
                          ),
                          pw.Text(
                            'DIME MARINE',
                            style: pw.TextStyle(fontSize: 5 * scale),
                          ),
                        ],
                      ),
              ),
              pw.SizedBox(width: 5 * scale),
              // Title
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'DIME MARINE SERVICES',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10 * scale,
                        decoration: pw.TextDecoration.underline,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 2 * scale),
                    pw.Text(
                      'CALIBRATED',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10 * scale,
                        decoration: pw.TextDecoration.underline,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4 * scale),

          // Data Table
          pw.Table(
            border: pw.TableBorder.all(width: 0.5 * scale),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              // Row 1: S/N and Cert.No
              pw.TableRow(
                children: [
                  _buildCell('S/N: ${certificate.serial}', scale, isBold: true),
                  _buildCell('Cert.No: ${certificate.certNo}', scale),
                ],
              ),
              // Row 2: Date and Due Date
              pw.TableRow(
                children: [
                  _buildCell(
                    'Date: ${certificate.formattedIssueDate}',
                    scale,
                    isBold: true,
                  ),
                  _buildCell(
                    'DueDate: ${certificate.formattedExpiryDate}',
                    scale,
                    isBold: true,
                  ),
                ],
              ),
              // Row 3: Set Pres and Test Medium
              pw.TableRow(
                children: [
                  _buildCell(
                    'Set.Pres: ${certificate.setPressure}',
                    scale,
                    isBold: true,
                  ),
                  _buildCell(
                    'Test Medium: ${certificate.testMedium}',
                    scale,
                    isBold: true,
                  ),
                ],
              ),
            ],
          ),

          pw.Spacer(),

          // Footer
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'www.dimemarine.com, Mob: +97430973432',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 7 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCell(String text, double scale, {bool isBold = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(
        horizontal: 4 * scale,
        vertical: 2 * scale,
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8 * scale,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
