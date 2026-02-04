import 'package:sticker_print_flutter/models/app_config.dart';
import 'package:sticker_print_flutter/services/odoo_client.dart';

/// Verify the hardcoded defaults work
void main() async {
  print('🔍 Testing Hardcoded Defaults...\n');

  // Create config with defaults (no params = uses hardcoded values)
  final config = AppConfig();

  print('📋 Default Configuration:');
  print('   URL: ${config.odooUrl}');
  print('   Database: ${config.database}');
  print('   Username: ${config.username}');
  print('   API Key: ${config.password.substring(0, 10)}...');
  print('   Certificate Model: ${config.modelCertificate}');
  print('   Is Valid: ${config.isValid}\n');

  if (!config.isValid) {
    print('❌ Config is not valid!');
    return;
  }

  try {
    final client = OdooClient(config);
    
    print('🔐 Testing authentication...');
    await client.authenticate();
    print('✅ Authentication successful!\n');

    print('📂 Fetching certificates...');
    final certs = await client.searchRead(
      'dm.certificate',
      [],
      ['id', 'name', 'serial_number'],
    );
    
    print('✅ Found ${certs.length} certificates!');
    if (certs.isNotEmpty) {
      print('   Sample: ${certs.first['name']}\n');
    }

    print('🎉 SUCCESS! The app will work immediately on first launch!');
    print('💡 No configuration needed - it\'s ready to go!\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }
}
