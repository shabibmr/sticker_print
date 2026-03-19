import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';
import '../models/app_config.dart';
import '../repositories/odoo_repository.dart';

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
  late TextEditingController _fieldTestedDateController;
  late TextEditingController _fieldSetPresController;
  late TextEditingController _fieldTestMediumController;
  late TextEditingController _labelWidthController;
  late TextEditingController _labelHeightController;

  // Local state using ValueNotifier to avoid setState for UI inputs
  late final ValueNotifier<String> _labelStyleNotifier;
  late final ValueNotifier<Printer?> _selectedPrinterNotifier;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    final config = context.read<SettingsBloc>().state.config;
    _initializeControllers(config);

    _labelStyleNotifier = ValueNotifier(config.labelStyle);
    _selectedPrinterNotifier = ValueNotifier(null);
  }

  void _initializeControllers(AppConfig config) {
    _urlController = TextEditingController(text: config.odooUrl);
    _databaseController = TextEditingController(text: config.database);
    _usernameController = TextEditingController(text: config.username);
    _passwordController = TextEditingController(text: config.password);
    _modelJobOrderController = TextEditingController(
      text: config.modelJobOrder,
    );
    _modelCertificateController = TextEditingController(
      text: config.modelCertificate,
    );
    _fieldRelationController = TextEditingController(
      text: config.fieldRelation,
    );
    _fieldSerialController = TextEditingController(text: config.fieldSerial);
    _fieldCertNoController = TextEditingController(text: config.fieldCertNo);
    _fieldIssueDateController = TextEditingController(
      text: config.fieldIssueDate,
    );
    _fieldExpiryDateController = TextEditingController(
      text: config.fieldExpiryDate,
    );
    _fieldTestedDateController = TextEditingController(
      text: config.fieldTestedDate,
    );
    _fieldSetPresController = TextEditingController(text: config.fieldSetPres);
    _fieldTestMediumController = TextEditingController(
      text: config.fieldTestMedium,
    );
    _labelWidthController = TextEditingController(
      text: config.labelWidth.toString(),
    );
    _labelHeightController = TextEditingController(
      text: config.labelHeight.toString(),
    );
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
    _fieldTestedDateController.dispose();
    _fieldSetPresController.dispose();
    _fieldTestMediumController.dispose();
    _labelWidthController.dispose();
    _labelHeightController.dispose();
    _labelStyleNotifier.dispose();
    _selectedPrinterNotifier.dispose();
    super.dispose();
  }

  void _saveSettings() {
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
      fieldTestedDate: _fieldTestedDateController.text.trim(),
      fieldSetPres: _fieldSetPresController.text.trim(),
      fieldTestMedium: _fieldTestMediumController.text.trim(),
      defaultPrinter: _selectedPrinterNotifier.value?.name,
      labelWidth: double.tryParse(_labelWidthController.text.trim()) ?? 30.0,
      labelHeight: double.tryParse(_labelHeightController.text.trim()) ?? 18.0,
      labelStyle: _labelStyleNotifier.value,
    );

    context.read<SettingsBloc>().add(UpdateSettings(newConfig));
  }

  void _testConnection() {
    final config = AppConfig(
      odooUrl: _urlController.text.trim(),
      database: _databaseController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    context.read<SettingsBloc>().add(TestConnection(config));
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
            Tab(text: 'Printing'),
            Tab(text: 'Advanced'),
          ],
        ),
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.loaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings saved successfully!')),
            );
          } else if (state.status == SettingsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildConnectionTab(state),
                _buildModelsTab(),
                _buildFieldsTab(),
                _buildPrintingTab(state),
                _buildAdvancedTab(context),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (_tabController.index == 0)
                Expanded(
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      final isTesting =
                          state.connectionStatus == ConnectionStatus.testing;
                      return OutlinedButton(
                        onPressed: isTesting ? null : _testConnection,
                        child: isTesting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Test Connection'),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    final isSaving = state.status == SettingsStatus.loading;
                    return ElevatedButton(
                      onPressed: isSaving ? null : _saveSettings,
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Settings'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionTab(SettingsState state) {
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
            decoration: const InputDecoration(labelText: 'Password / API Key'),
          ),
          if (state.connectionStatus != ConnectionStatus.initial) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  state.connectionMessage ?? '',
                  style: TextStyle(
                    color: state.connectionStatus == ConnectionStatus.success
                        ? Colors.green
                        : (state.connectionStatus == ConnectionStatus.failure
                              ? Colors.red
                              : Colors.blue),
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
          const SizedBox(height: 16),
          TextField(
            controller: _fieldTestedDateController,
            decoration: const InputDecoration(
              labelText: 'Tested Date Field',
              hintText: 'tested_date',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fieldSetPresController,
            decoration: const InputDecoration(
              labelText: 'Set Pressure Field',
              hintText: 'set_pressure',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fieldTestMediumController,
            decoration: const InputDecoration(
              labelText: 'Test Medium Field',
              hintText: 'test_medium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export Configuration'),
          onTap: () {
            final config = context.read<SettingsBloc>().state.config;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Config: ${config.toString()}')),
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
                content: const Text(
                  'This will reset all settings to defaults.',
                ),
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

            if (confirmed == true && context.mounted) {
              context.read<SettingsBloc>().add(ResetSettings());
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Analyze Certificates'),
          subtitle: const Text(
            'Fetch 15 random certificates and dump data to file',
          ),
          onTap: () async {
            try {
              final result = await context
                  .read<OdooRepository>()
                  .analyzeCertificates();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result)));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildPrintingTab(SettingsState state) {
    // Initial sync for selected printer
    if (_selectedPrinterNotifier.value == null &&
        state.config.defaultPrinter != null &&
        state.printers.isNotEmpty) {
      try {
        _selectedPrinterNotifier.value = state.printers.firstWhere(
          (p) => p.name == state.config.defaultPrinter,
        );
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Default Printer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (state.isLoadingPrinters)
                    const Center(child: CircularProgressIndicator())
                  else
                    ValueListenableBuilder<Printer?>(
                      valueListenable: _selectedPrinterNotifier,
                      builder: (context, selectedPrinter, _) {
                        return DropdownButtonFormField<Printer>(
                          value: selectedPrinter,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<Printer>(
                              value: null,
                              child: Text(
                                'Select a printer (Default System Dialog)',
                              ),
                            ),
                            ...state.printers.map(
                              (printer) => DropdownMenuItem(
                                value: printer,
                                child: Text(printer.name),
                              ),
                            ),
                          ],
                          onChanged: (Printer? value) {
                            _selectedPrinterNotifier.value = value;
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'If a printer is selected, the app will try to print directly to it.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Label Style',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: _labelStyleNotifier,
                    builder: (context, labelStyle, _) {
                      return DropdownButtonFormField<String>(
                        value: labelStyle,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'dime_marine',
                            child: Text('Dime Marine'),
                          ),
                          DropdownMenuItem(
                            value: 'style_1',
                            child: Text('Tested'),
                          ),
                          DropdownMenuItem(
                            value: 'style_2',
                            child: Text('Calibrated'),
                          ),
                          DropdownMenuItem(
                            value: 'style_3',
                            child: Text('Tested (Custom Font)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _labelStyleNotifier.value = value;
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Label Dimensions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: (() {
                      final w =
                          double.tryParse(_labelWidthController.text) ?? 0;
                      final h =
                          double.tryParse(_labelHeightController.text) ?? 0;
                      final key = '${h.toInt()}-${w.toInt()}';
                      const validKeys = ['12-28', '18-30', '24-38'];
                      return validKeys.contains(key) ? key : '18-30';
                    })(),
                    decoration: const InputDecoration(
                      labelText: 'Label Size',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '12-28',
                        child: Text('28mm x 12mm (Small)'),
                      ),
                      DropdownMenuItem(
                        value: '18-30',
                        child: Text('30mm x 18mm (Medium)'),
                      ),
                      DropdownMenuItem(
                        value: '24-38',
                        child: Text('38mm x 24mm (Large)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        final parts = value.split('-');
                        setState(() {
                          _labelHeightController.text = parts[0];
                          _labelWidthController.text = parts[1];
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
