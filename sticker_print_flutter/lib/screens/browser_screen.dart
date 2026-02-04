import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import '../services/odoo_client.dart';
import '../models/certificate.dart';
import 'preview_screen.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Certificate> _certificates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates({String searchTerm = ''}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final config = Provider.of<ConfigService>(context, listen: false).config;
      final client = OdooClient(config);

      final certificates = await client.searchCertificates(
        searchTerm: searchTerm,
      );

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

  Future<void> _onCertificateSelected(Certificate preliminaryCert) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final config = Provider.of<ConfigService>(context, listen: false).config;
      final client = OdooClient(config);

      // Fetch full details
      final fullCert = await client.getCertificateDetails(preliminaryCert.id);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to preview
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PreviewScreen(certificate: fullCert),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading certificate details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('☁️ Browse Certificates')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search certificates...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadCertificates();
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) => _loadCertificates(searchTerm: value),
            ),
          ),

          // Loading / Error / Results
          Expanded(
            child: _isLoading
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
                            'Error loading data',
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
                ? const Center(child: Text('No certificates found'))
                : ListView.builder(
                    itemCount: _certificates.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final cert = _certificates[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: const Icon(Icons.confirmation_number),
                          ),
                          title: Text(cert.name),
                          subtitle: Text(
                            cert.serial.isNotEmpty
                                ? 'S/N: ${cert.serial}'
                                : 'ID: ${cert.id}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _onCertificateSelected(cert),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
