import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/settings_repository.dart';
import 'repositories/odoo_repository.dart';
import 'blocs/connectivity/connectivity_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_event.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => SettingsRepository()),
        RepositoryProvider(create: (context) => OdooRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsRepository: context.read<SettingsRepository>(),
            )..add(LoadSettings()),
          ),
          BlocProvider<ConnectivityBloc>(
            create: (context) => ConnectivityBloc(
              odooRepository: context.read<OdooRepository>(),
              settingsBloc: context.read<SettingsBloc>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Sticker Printer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8E7CFF),
              brightness: Brightness.light,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
