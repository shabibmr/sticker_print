import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../blocs/sticker/sticker_bloc.dart';
import '../blocs/sticker/sticker_event.dart';
import '../blocs/sticker/sticker_state.dart';
import '../repositories/odoo_repository.dart';
import '../blocs/settings/settings_bloc.dart';
import '../widgets/label_style_1.dart';
import '../widgets/label_style_2.dart';
import '../widgets/label_style_3.dart';

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject StickerBloc scoped to this screen
    return BlocProvider(
      create: (context) => StickerBloc(
        odooRepository: context.read<OdooRepository>(),
        initialConfig: context.read<SettingsBloc>().state.config,
      ),
      child: const _BrowserScreenContent(),
    );
  }
}

class _BrowserScreenContent extends StatelessWidget {
  const _BrowserScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('☁️ Browse Certificates')),
      body: Row(
        children: [
          // LEFT PANEL - Certificates List
          Expanded(
            flex: 35,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search certificates...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      context.read<StickerBloc>().add(
                        SearchCertificates(value),
                      );
                    },
                  ),
                ),

                // Loading / Error / Results
                Expanded(
                  child: BlocBuilder<StickerBloc, StickerState>(
                    buildWhen: (previous, current) =>
                        previous.status != current.status ||
                        previous.certificates != current.certificates ||
                        previous.selectedCertificate !=
                            current.selectedCertificate,
                    builder: (context, state) {
                      if (state.status == StickerStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.status == StickerStatus.error) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading data',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(state.errorMessage ?? 'Unknown error'),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<StickerBloc>().add(
                                      const SearchCertificates(''),
                                    );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (state.certificates.isEmpty) {
                        return const Center(
                          child: Text('No certificates found'),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.certificates.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final cert = state.certificates[index];
                          final isSelected =
                              state.selectedCertificate?.id == cert.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: isSelected ? 0 : 1,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                  child: Icon(
                                    Icons.confirmation_number,
                                    color: isSelected ? Colors.white : null,
                                  ),
                                ),
                                title: Text(cert.name),
                                subtitle: Text(
                                  cert.serial.isNotEmpty
                                      ? 'S/N: ${cert.serial}'
                                      : 'ID: ${cert.id}',
                                ),
                                onTap: () {
                                  context.read<StickerBloc>().add(
                                    SelectCertificate(cert),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1),

          // RIGHT PANEL - Preview
          Expanded(
            flex: 65,
            child: BlocBuilder<StickerBloc, StickerState>(
              builder: (context, state) {
                if (state.selectedCertificate == null) {
                  return const _EmptyPreview();
                } else {
                  return const _LabelPreview();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.label_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Select a certificate to preview',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _LabelPreview extends StatelessWidget {
  const _LabelPreview();

  Future<void> _handlePrint(BuildContext context, StickerState state) async {
    await Printing.layoutPdf(
      format: PdfPageFormat(
        state.labelWidth * PdfPageFormat.mm,
        state.labelHeight * PdfPageFormat.mm,
        marginAll: 0,
      ),
      onLayout: (PdfPageFormat format) async {
        final logo = await _loadLogo();
        final font = await _loadFont();
        final fontBold = await _loadFontBold();
        final doc = pw.Document(
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        );

        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              state.labelWidth * PdfPageFormat.mm,
              state.labelHeight * PdfPageFormat.mm,
              marginAll: 0,
            ),
            build: (context) =>
                _buildPdfLabel(state, isPreview: false, logoImage: logo),
          ),
        );

        return doc.save();
      },
    );
  }

  Future<pw.MemoryImage> _loadLogo() async {
    final data = await rootBundle.load('assets/logo1.jpeg');
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  Future<pw.Font> _loadFont() async {
    if (!kIsWeb && Platform.isWindows) {
      try {
        final bytes = await File('C:/Windows/Fonts/arial.ttf').readAsBytes();
        return pw.Font.ttf(bytes.buffer.asByteData());
      } catch (_) {}
    }
    return pw.Font.helvetica();
  }

  Future<pw.Font> _loadFontBold() async {
    if (!kIsWeb && Platform.isWindows) {
      try {
        final bytes = await File('C:/Windows/Fonts/arialbd.ttf').readAsBytes();
        return pw.Font.ttf(bytes.buffer.asByteData());
      } catch (_) {}
    }
    return pw.Font.helveticaBold();
  }

  pw.Widget _buildPdfLabel(
    StickerState state, {
    bool isPreview = false,
    pw.ImageProvider? logoImage,
  }) {
    if (state.labelStyle == 'dime_marine') {
      return _buildDimeMarinePdfLabel(state, logoImage: logoImage);
    } else if (state.labelStyle == 'style_2') {
      return LabelStyle2(
        certificate: state.selectedCertificate!,
        isPreview: isPreview,
        logoImage: logoImage,
        labelWidth: state.labelWidth,
        labelHeight: state.labelHeight,
        fontSize: state.fontSize,
      );
    } else if (state.labelStyle == 'style_3') {
      return LabelStyle3(
        certificate: state.selectedCertificate!,
        isPreview: isPreview,
        logoImage: logoImage,
        labelWidth: state.labelWidth,
        labelHeight: state.labelHeight,
        headerFontSizeMm: state.style3HeaderFontMm,
        subHeaderFontSizeMm: state.style3SubHeaderFontMm,
        fieldFontSizeMm: state.style3FieldFontMm,
        footerFontSizeMm: state.style3FooterFontMm,
      );
    }

    return LabelStyle1(
      certificate: state.selectedCertificate!,
      isPreview: isPreview,
      logoImage: logoImage,
      labelWidth: state.labelWidth,
      labelHeight: state.labelHeight,
      fontSize: state.fontSize,
    );
  }

  pw.Widget _buildDimeMarinePdfLabel(
    StickerState state, {
    pw.ImageProvider? logoImage,
  }) {
    final cert = state.selectedCertificate!;
    final double w = state.labelWidth * PdfPageFormat.mm;
    final double h = state.labelHeight * PdfPageFormat.mm;
    final double fs = state.fontSize;

    // Design at a fixed reference size, then FittedBox scales to fit
    const double refW = 310;
    const double refH = 170;

    return pw.Container(
      width: w,
      height: h,
      padding: pw.EdgeInsets.all(state.borderInset),
      child: pw.Container(
        decoration: state.showBorder
            ? pw.BoxDecoration(border: pw.Border.all(width: 0.5))
            : null,
        padding: pw.EdgeInsets.all(state.contentPadding),
        child: pw.FittedBox(
          fit: pw.BoxFit.contain,
          child: pw.SizedBox(
            width: refW,
            height: refH,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Header: Logo + Title
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Logo
                      pw.Container(
                        width: 55,
                        height: 50,
                        alignment: pw.Alignment.center,
                        child: logoImage != null
                            ? pw.Image(logoImage, width: 50, height: 48)
                            : pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Container(
                                    width: 30,
                                    height: 30,
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border.all(width: 1),
                                      shape: pw.BoxShape.circle,
                                    ),
                                    child: pw.Center(
                                      child: pw.Text(
                                        'D',
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(
                                    'DIME MARINE',
                                    style: pw.TextStyle(
                                      fontSize: 6,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      pw.SizedBox(width: 8),
                      // Title
                      pw.Expanded(
                        child: pw.Column(
                          children: [
                            pw.SizedBox(height: 6),
                            pw.Text(
                              'DIME MARINE SERVICES',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                decoration: pw.TextDecoration.underline,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'CALIBRATED',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 14,
                                decoration: pw.TextDecoration.underline,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Data Table
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(4),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          _buildDimeCell(
                            'S/N: ${cert.serial}',
                            fs,
                            isBold: true,
                          ),
                          _buildDimeCell('Cert.No: ${cert.shortCertNo}', fs),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildDimeCell(
                            'Date: ${cert.formattedIssueDate}',
                            fs,
                            isBold: true,
                          ),
                          _buildDimeCell(
                            'DueDate: ${cert.formattedExpiryDate}',
                            fs,
                            isBold: true,
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildDimeCell(
                            'Set.Pres: ${cert.setPressure}',
                            fs,
                            isBold: true,
                          ),
                          _buildDimeCell(
                            'Test Medium: ${cert.testMedium}',
                            fs,
                            isBold: true,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Footer
                  pw.Text(
                    'www.dimemarine.com, Mob: +97430973432',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildDimeCell(
    String text,
    double fontSize, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StickerBloc, StickerState>(
      builder: (context, state) {
        if (state.isLoadingDetails) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Preview Header with Print Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Preview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handlePrint(context, state),
                    icon: const Icon(Icons.print),
                    label: const Text('Print Label'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Preview Stage
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: AspectRatio(
                    aspectRatio: state.labelWidth / state.labelHeight,
                    child: PdfPreview(
                      build: (format) async {
                        final logo = await _loadLogo();
                        final font = await _loadFont();
                        final fontBold = await _loadFontBold();
                        final doc = pw.Document(
                          theme: pw.ThemeData.withFont(
                            base: font,
                            bold: fontBold,
                          ),
                        );
                        doc.addPage(
                          pw.Page(
                            pageFormat: PdfPageFormat(
                              state.labelWidth * PdfPageFormat.mm,
                              state.labelHeight * PdfPageFormat.mm,
                              marginAll: 0,
                            ),
                            build: (context) => _buildPdfLabel(
                              state,
                              isPreview: true,
                              logoImage: logo,
                            ),
                          ),
                        );
                        return doc.save();
                      },
                      useActions: false,
                      padding: EdgeInsets.zero,
                      scrollViewDecoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dimensions Display
              Text(
                'Dimensions: ${state.labelWidth.toStringAsFixed(0)}mm x ${state.labelHeight.toStringAsFixed(0)}mm',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 24),

              // Configuration Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Configuration',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Label Style
                      _buildSettingRow(
                        'Label Style',
                        DropdownButton<String>(
                          value: state.labelStyle,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'dime_marine',
                              child: Text('Dime Marine'),
                            ),
                            DropdownMenuItem(
                              value: 'style_1',
                              child: Text('Tested'),
                            ),
                            DropdownMenuItem(
                              value: 'style_2',
                              child: Text('Calibrated'),
                            ),
                            DropdownMenuItem(
                              value: 'style_3',
                              child: Text('Tested (Custom Font)'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              context.read<StickerBloc>().add(
                                UpdateLabelConfig(style: value),
                              );
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sticker Size
                      Builder(
                        builder: (context) {
                          final currentH = state.labelHeight.toInt();
                          final currentW = state.labelWidth.toInt();
                          final currentKey = '$currentH-$currentW';
                          const validKeys = ['12-28', '18-30', '24-38'];

                          // Default to Large (24-38) if current is invalid, to prevent crash
                          final dropdownValue = validKeys.contains(currentKey)
                              ? currentKey
                              : '18-30';

                          return _buildSettingRow(
                            'Sticker Size',
                            DropdownButton<String>(
                              value: dropdownValue,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: '12-28',
                                  child: Text('28mm x 12mm (Small)'),
                                ),
                                DropdownMenuItem(
                                  value: '18-30',
                                  child: Text('30mm x 18mm (Medium)'),
                                ),
                                DropdownMenuItem(
                                  value: '24-38',
                                  child: Text('38mm x 24mm (Large)'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  final parts = value.split('-');
                                  context.read<StickerBloc>().add(
                                    UpdateLabelConfig(
                                      height: double.parse(parts[0]),
                                      width: double.parse(parts[1]),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Filter parameters
                      _buildSliderRow(
                        'Border Margin (Inset)',
                        state.borderInset,
                        0,
                        6,
                        'mm',
                        (value) => context.read<StickerBloc>().add(
                          UpdateLabelConfig(borderInset: value),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildSliderRow(
                        'Content Margin (Padding)',
                        state.contentPadding,
                        0,
                        6,
                        'mm',
                        (value) => context.read<StickerBloc>().add(
                          UpdateLabelConfig(contentPadding: value),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildSliderRow(
                        'Base Font Size',
                        state.fontSize,
                        4,
                        14,
                        'pt',
                        (value) => context.read<StickerBloc>().add(
                          UpdateLabelConfig(fontSize: value),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildSliderRow(
                        'Line Gap',
                        state.lineGap,
                        0,
                        5,
                        'mm',
                        (value) => context.read<StickerBloc>().add(
                          UpdateLabelConfig(lineGap: value),
                        ),
                      ),

                      // Per-line font size controls (style_3 only)
                      if (state.labelStyle == 'style_3') ...[
                        const SizedBox(height: 20),
                        Text(
                          'Per-Line Font Sizes',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Divider(height: 16),
                        _buildSliderRow(
                          'Header (Company Name)',
                          state.style3HeaderFontMm,
                          0.5,
                          5.0,
                          'mm',
                          (value) => context.read<StickerBloc>().add(
                            UpdateLabelConfig(style3HeaderFontMm: value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSliderRow(
                          'Sub-Header (TESTED)',
                          state.style3SubHeaderFontMm,
                          0.5,
                          5.0,
                          'mm',
                          (value) => context.read<StickerBloc>().add(
                            UpdateLabelConfig(style3SubHeaderFontMm: value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSliderRow(
                          'Data Fields (S/N, Dates, Cert)',
                          state.style3FieldFontMm,
                          0.5,
                          5.0,
                          'mm',
                          (value) => context.read<StickerBloc>().add(
                            UpdateLabelConfig(style3FieldFontMm: value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSliderRow(
                          'Footer (Website / Phone)',
                          state.style3FooterFontMm,
                          0.5,
                          5.0,
                          'mm',
                          (value) => context.read<StickerBloc>().add(
                            UpdateLabelConfig(style3FooterFontMm: value),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Show Border Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Border',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: state.showBorder,
                            onChanged: (value) {
                              context.read<StickerBloc>().add(
                                UpdateLabelConfig(showBorder: value),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingRow(String label, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        control,
      ],
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    String unit,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) * 2).toInt(),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              child: Text(
                '${value.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
