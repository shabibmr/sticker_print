import '../services/config_service.dart';
import '../models/app_config.dart';

class SettingsRepository {
  final ConfigService _configService;

  SettingsRepository({ConfigService? configService})
    : _configService = configService ?? ConfigService();

  Future<AppConfig> loadSettings() async {
    return await _configService.load();
  }

  Future<void> saveSettings(AppConfig config) async {
    await _configService.save(config);
  }

  Future<void> resetSettings() async {
    await _configService.reset();
  }

  AppConfig get currentConfig => _configService.config;
}
