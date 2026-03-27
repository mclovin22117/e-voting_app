import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/voter_home_screen.dart';
import 'services/blockchain_service.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final blockchainService = BlockchainService(config: config);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Voting Mobile',
      home: const AuthScreen(),
      routes: {
        VoterHomeScreen.routeName: (context) =>
            VoterHomeScreen(blockchainService: blockchainService),
        AdminDashboardScreen.routeName: (context) =>
            AdminDashboardScreen(
              config: config,
              blockchainService: blockchainService,
            ),
      },
    );
  }
}