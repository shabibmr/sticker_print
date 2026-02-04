import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/certificate.dart';

class PreviewScreen extends StatefulWidget {
  final Certificate? certificate;
  final bool isManual;

  const PreviewScreen({
    super.key,
    this.certificate,
    this.isManual = false,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _certNoController = TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  // Label configuration
  final double _labelWidth = 101.6; // mm
  final double _labelHeight = 50.8; // mm
  double _fontSize = 8.0;
  bool _showBorder = true;

  @override
  void initState() {
    super.initState();
    
    final cert = widget.certificate;
    _serialController.text = cert?.serial ?? '';
    _certNoController.text = cert?.certNo ?? '';
    _issueDateController.text = cert?.formattedIssueDate ?? '';
    _expiryDateController.text = cert?.formattedExpiryDate ?? '';
  }

  @override
  void dispose() {
    _serialController.dispose();
    _certNoController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  pw.Widget _buildPdfLabel() {
    return pw.Container(
      width: _labelWidth * PdfPageFormat.mm,
      height: _labelHeight * PdfPageFormat.mm,
      decoration: _showBorder
          ? pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
            )
          : null,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Serial Number
          if (_serialController.text.isNotEmpty)
            pw.Text(
              'S/N: ${_serialController.text}',
              style: pw.TextStyle(
                fontSize: _fontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          
          // Certificate Number
          if (_certNoController.text.isNotEmpty)
            pw.Text(
              'Cert: ${_certNoController.text}',
              style: pw.TextStyle(fontSize: _fontSize),
            ),
          
          pw.Spacer(),
          
          // Dates
          if (_issueDateController.text.isNotEmpty)
            pw.Text(
              'Issued: ${_issueDateController.text}',
              style: pw.TextStyle(fontSize: _fontSize - 1),
            ),
          if (_expiryDateController.text.isNotEmpty)
            pw.Text(
              'Expiry: ${_expiryDateController.text}',
              style: pw.TextStyle(fontSize: _fontSize - 1),
            ),
        ],
      ),
    );
  }

  Future<void> _handlePrint() async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();
        
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              _labelWidth * PdfPageFormat.mm,
              _labelHeight * PdfPageFormat.mm,
              marginAll: 0,
            ),
            build: (context) => _buildPdfLabel(),
          ),
        );
        
        return doc.save();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏷️ Label Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _handlePrint,
            tooltip: 'Print Label',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Live Preview
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: _labelWidth / _labelHeight,
                child: PdfPreview(
                  build: (format) async {
                    final doc = pw.Document();
                    doc.addPage(
                      pw.Page(
                        pageFormat: PdfPageFormat(
                          _labelWidth * PdfPageFormat.mm,
                          _labelHeight * PdfPageFormat.mm,
                          marginAll: 0,
                        ),
                        build: (context) => _buildPdfLabel(),
                      ),
                    );
                    return doc.save();
                  },
                  canChangeOrientation: false,
                  canDebug: false,
                  canChangePageFormat: false,
                ),
              ),
            ),

            // Input Fields
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Label Content',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _serialController,
                    decoration: const InputDecoration(
                      labelText: 'Serial Number',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _certNoController,
                    decoration: const InputDecoration(
                      labelText: 'Certificate Number',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _issueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Issue Date',
                      hintText: 'DD/MM/YYYY',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _expiryDateController,
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'DD/MM/YYYY',
                      prefixIcon: Icon(Icons.event),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Label Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Font Size
                  Row(
                    children: [
                      const Expanded(child: Text('Font Size')),
                      Expanded(
                        flex: 2,
                        child: Slider(
                          value: _fontSize,
                          min: 6,
                          max: 14,
                          divisions: 16,
                          label: _fontSize.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() => _fontSize = value);
                          },
                        ),
                      ),
                      Text(_fontSize.toStringAsFixed(1)),
                    ],
                  ),
                  
                  // Show Border
                  SwitchListTile(
                    title: const Text('Show Border'),
                    value: _showBorder,
                    onChanged: (value) {
                      setState(() => _showBorder = value);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Print Button
                  ElevatedButton.icon(
                    onPressed: _handlePrint,
                    icon: const Icon(Icons.print),
                    label: const Text('Print Label'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
