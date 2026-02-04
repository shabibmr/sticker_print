import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Auto-configure the app with Dime Marine settings
void main() async {
  print('⚙️  Auto-configuring Flutter app for Dime Marine Odoo...\n');

  final config = {
    'odooUrl': 'https://test2.graycodeanalytica.com',
    'database': 'run.qatar.dimemarine.com.001',
    'username': 'api_user@dimemarine.com',
    'password': '1ddf392b3daf7b0344cb7a82c9b2dc43a4dc5004',
    'modelJobOrder': 'sale.order',
    'modelCertificate': 'dm.certificate',
    'fieldRelation': 'order_id',
    'fieldSerial': 'serial_number',
    'fieldCertNo': 'name',
    'fieldIssueDate': 'calibration_date',
    'fieldExpiryDate': 'date_expiry',
  };

  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(config);
  await prefs.setString('odoo_printer_config', jsonString);

  print('✅ Configuration saved!');
  print('\nSettings:');
  print('  • Odoo URL: ${config['odooUrl']}');
  print('  • Database: ${config['database']}');
  print('  • Certificate Model: ${config['modelCertificate']}');
  print('  • Fields: serial_number, name, calibration_date, date_expiry');
  print('\n🎉 App is ready to use!');
  print('💡 Restart the Flutter app (press R in terminal) to load the config.\n');
}
