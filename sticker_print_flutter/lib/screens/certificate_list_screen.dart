import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import '../services/odoo_client.dart';
import '../models/job_order.dart';
import '../models/certificate.dart';
import 'preview_screen.dart';

class CertificateListScreen extends StatefulWidget {
  final JobOrder jobOrder;

  const CertificateListScreen({
    super.key,
    required this.jobOrder,
  });

  @override
  State<CertificateListScreen> createState() => _CertificateListScreenState();
}

class _CertificateListScreenState extends State<CertificateListScreen> {
  List<Certificate> _certificates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final config = Provider.of<ConfigService>(context, listen: false).config;
      final client = OdooClient(config);
      
      final certificates = await client.listCertificates(widget.jobOrder.id);
      
      setState(() {
        _certificates = certificates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📜 ${widget.jobOrder.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                          'Error loading certificates',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(_errorMessage!),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadCertificates,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _certificates.isEmpty
                  ? const Center(
                      child: Text('No certificates found for this job order'),
                    )
                  : ListView.builder(
                      itemCount: _certificates.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final cert = _certificates[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.label,
                                color: Color(0xFF8E7CFF),
                              ),
                            ),
                            title: Text(cert.serial.isNotEmpty
                                ? 'S/N: ${cert.serial}'
                                : cert.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (cert.certNo.isNotEmpty)
                                  Text('Cert: ${cert.certNo}'),
                                if (cert.formattedIssueDate.isNotEmpty)
                                  Text('Issued: ${cert.formattedIssueDate}'),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.print),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PreviewScreen(
                                    certificate: cert,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
