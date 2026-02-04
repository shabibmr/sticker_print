import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import 'settings_screen.dart';
import 'browser_screen.dart';
import 'preview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configService = Provider.of<ConfigService>(context);
    final isConfigured = configService.config.isValid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ Label Studio'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.print,
                size: 80,
                color: Color(0xFF8E7CFF),
              ),
              const SizedBox(height: 24),
              const Text(
                'Odoo Label Printer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isConfigured
                    ? 'Connected to Odoo ✓'
                    : 'Not configured',
                style: TextStyle(
                  fontSize: 16,
                  color: isConfigured ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 48),
              
              // Browse Odoo button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isConfigured
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BrowserScreen()),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.cloud),
                  label: const Text('Browse Odoo Data'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Manual entry button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PreviewScreen(isManual: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Manual Entry'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              if (!isConfigured) ...[
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Configure Odoo Connection'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
