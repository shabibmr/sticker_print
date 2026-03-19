import '../services/odoo_client.dart';
import '../models/app_config.dart';
import '../models/certificate.dart';

class OdooRepository {
  OdooClient? _client;
  AppConfig? _currentConfig;

  void initialize(AppConfig config) {
    if (_currentConfig == config) return;
    _currentConfig = config;
    _client = OdooClient(config);
  }

  Future<int> authenticate() async {
    if (_client == null) throw Exception('Odoo client not initialized');
    return await _client!.authenticate();
  }

  Future<List<Certificate>> searchCertificates({String searchTerm = ''}) async {
    if (_client == null) throw Exception('Odoo client not initialized');
    return await _client!.searchCertificates(searchTerm: searchTerm);
  }

  Future<Certificate> getCertificateDetails(int id) async {
    if (_client == null) throw Exception('Odoo client not initialized');
    return await _client!.getCertificateDetails(id);
  }

  Future<String> analyzeCertificates() async {
    if (_client == null) throw Exception('Odoo client not initialized');
    return await _client!.analyzeCertificates();
  }
}
