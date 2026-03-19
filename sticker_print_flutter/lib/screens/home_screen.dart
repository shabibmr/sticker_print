import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/connectivity/connectivity_bloc.dart';
import '../blocs/connectivity/connectivity_event.dart';
import '../blocs/connectivity/connectivity_state.dart';
import 'settings_screen.dart';
import 'browser_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeScreen no longer needs its own internal Bloc if we just use global ConnectivityBloc
    // But if we want to keep HomeBloc for other things, we can.
    // user asked for "bloc for Home page" earlier, which we did.
    // Now we enhance it or replace it.
    // ConnectivityBloc is global, so we can just use it.
    // Let's use ConnectivityBloc directly for the status.

    return const _HomeScreenContent();
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ Label Studio'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ConnectivityBloc>().add(CheckConnectivity());
            },
          ),
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
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, state) {
          final status = state.status;
          final isConnected = status == ConnectivityStatus.connected;

          Color statusColor;
          String statusText;
          IconData statusIcon;

          switch (status) {
            case ConnectivityStatus.initial:
              statusColor = Colors.grey;
              statusText = 'Checking connection...';
              statusIcon = Icons.sensors;
              break;
            case ConnectivityStatus.connecting:
              statusColor = Colors.blue;
              statusText = 'Connecting to Odoo...';
              statusIcon = Icons.sensors;
              break;
            case ConnectivityStatus.connected:
              statusColor = Colors.green;
              statusText = 'Connected to Odoo';
              statusIcon = Icons.check_circle;
              break;
            case ConnectivityStatus.disconnected:
              statusColor = Colors.orange;
              statusText = 'Not Connected';
              statusIcon = Icons.sensors_off;
              break;
            case ConnectivityStatus.error:
              statusColor = Colors.red;
              statusText = 'Connection Error';
              statusIcon = Icons.error_outline;
              break;
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.print, size: 80, color: Color(0xFF8E7CFF)),
                  const SizedBox(height: 24),
                  const Text(
                    'Odoo Label Printer',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status == ConnectivityStatus.connecting)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: statusColor,
                            ),
                          )
                        else
                          Icon(statusIcon, size: 18, color: statusColor),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (status == ConnectivityStatus.error &&
                      state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 48),

                  // Browse Odoo button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: isConnected
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BrowserScreen(),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.cloud),
                      label: const Text('Browse Odoo Data'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF8E7CFF),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  if (!isConnected) ...[
                    const SizedBox(height: 32),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Configure Odoo Connection'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
