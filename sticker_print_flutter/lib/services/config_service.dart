import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';

/// Service for managing application configuration using SharedPreferences
class ConfigService {
  static const String _configKey = 'odoo_printer_config';
  
  AppConfig _config = AppConfig();
  
  /// Get current configuration
  AppConfig get config => _config;

  /// Load configuration from storage
  Future<AppConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_configKey);
    
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _config = AppConfig.fromJson(json);
      } catch (e) {
        debugPrint('Error loading config: $e');
        _config = AppConfig(); // Use defaults on error
      }
    } else {
      _config = AppConfig(); // Use defaults if no saved config
    }
    
    return _config;
  }

  /// Save configuration to storage
  Future<void> save(AppConfig newConfig) async {
    _config = newConfig;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_config.toJson());
    await prefs.setString(_configKey, jsonString);
  }

  /// Reset to default configuration
  Future<void> reset() async {
    _config = AppConfig();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_configKey);
  }

  /// Export configuration as JSON string
  String exportToJson() {
    return jsonEncode(_config.toJson());
  }

  /// Import configuration from JSON string
  Future<bool> importFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final newConfig = AppConfig.fromJson(json);
      await save(newConfig);
      return true;
    } catch (e) {
      debugPrint('Error importing config: $e');
      return false;
    }
  }
}
