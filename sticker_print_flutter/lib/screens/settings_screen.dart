import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/config_service.dart';
import '../services/odoo_client.dart';
import '../models/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _urlController;
  late TextEditingController _databaseController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _modelJobOrderController;
  late TextEditingController _modelCertificateController;
  late TextEditingController _fieldRelationController;
  late TextEditingController _fieldSerialController;
  late TextEditingController _fieldCertNoController;
  late TextEditingController _fieldIssueDateController;
  late TextEditingController _fieldExpiryDateController;

  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final config = Provider.of<ConfigService>(context, listen: false).config;
    
    _urlController = TextEditingController(text: config.odooUrl);
    _databaseController = TextEditingController(text: config.database);
    _usernameController = TextEditingController(text: config.username);
    _passwordController = TextEditingController(text: config.password);
    _modelJobOrderController = TextEditingController(text: config.modelJobOrder);
    _modelCertificateController = TextEditingController(text: config.modelCertificate);
    _fieldRelationController = TextEditingController(text: config.fieldRelation);
    _fieldSerialController = TextEditingController(text: config.fieldSerial);
    _fieldCertNoController = TextEditingController(text: config.fieldCertNo);
    _fieldIssueDateController = TextEditingController(text: config.fieldIssueDate);
    _fieldExpiryDateController = TextEditingController(text: config.fieldExpiryDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _modelJobOrderController.dispose();
    _modelCertificateController.dispose();
    _fieldRelationController.dispose();
    _fieldSerialController.dispose();
    _fieldCertNoController.dispose();
    _fieldIssueDateController.dispose();
    _fieldExpiryDateController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final newConfig = AppConfig(
      odooUrl: _urlController.text.trim(),
      database: _databaseController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      modelJobOrder: _modelJobOrderController.text.trim(),
      modelCertificate: _modelCertificateController.text.trim(),
      fieldRelation: _fieldRelationController.text.trim(),
      fieldSerial: _fieldSerialController.text.trim(),
      fieldCertNo: _fieldCertNoController.text.trim(),
      fieldIssueDate: _fieldIssueDateController.text.trim(),
      fieldExpiryDate: _fieldExpiryDateController.text.trim(),
    );

    await Provider.of<ConfigService>(context, listen: false).save(newConfig);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  Future<void> _testConnection() async {
    final config = AppConfig(
      odooUrl: _urlController.text.trim(),
      database: _databaseController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!config.isValid) {
      setState(() {
        _statusMessage = '❌ Please fill in all connection fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing connection...';
    });

    try {
      final client = OdooClient(config);
      final uid = await client.authenticate();
      
      setState(() {
        _isLoading = false;
        _statusMessage = '✅ Connection successful! User ID: $uid';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Configuration'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Connection'),
            Tab(text: 'Models'),
            Tab(text: 'Fields'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionTab(),
          _buildModelsTab(),
          _buildFieldsTab(),
          _buildAdvancedTab(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (_tabController.index == 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Test Connection'),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Server URL',
              hintText: 'https://your-odoo-instance.com',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _databaseController,
            decoration: const InputDecoration(
              labelText: 'Database Name',
              hintText: 'odoo_db',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username / Email',
              hintText: 'admin',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password / API Key',
            ),
          ),
          if (_statusMessage.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.startsWith('✅')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _modelJobOrderController,
            decoration: const InputDecoration(
              labelText: 'Job Order Model',
              hintText: 'sale.order',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _modelCertificateController,
            decoration: const InputDecoration(
              labelText: 'Certificate Model',
              hintText: 'dm.certificate',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fieldRelationController,
            decoration: const InputDecoration(
              labelText: 'Link Field (in Certificate)',
              hintText: 'order_id',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _fieldSerialController,
            decoration: const InputDecoration(
              labelText: 'Serial Number Field',
              hintText: 'serial_number',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fieldCertNoController,
            decoration: const InputDecoration(
              labelText: 'Certificate No Field',
              hintText: 'name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fieldIssueDateController,
            decoration: const InputDecoration(
              labelText: 'Calibration Date Field',
              hintText: 'calibration_date',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fieldExpiryDateController,
            decoration: const InputDecoration(
              labelText: 'Expiry Date Field',
              hintText: 'date_expiry',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export Configuration'),
          onTap: () async {
            final configService = Provider.of<ConfigService>(context, listen: false);
            final json = configService.exportToJson();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Config: $json')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Reset to Defaults'),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reset Settings?'),
                content: const Text('This will reset all settings to defaults.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
            
            if (confirmed == true && mounted) {
              await Provider.of<ConfigService>(context, listen: false).reset();
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
