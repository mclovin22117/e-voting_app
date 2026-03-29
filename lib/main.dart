import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'controllers/auth_controller.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/register_screen.dart';
import 'screens/voter_home_screen.dart';
import 'services/backend_api_service.dart';
import 'services/blockchain_service.dart';
import 'services/session_storage_service.dart';
import 'services/wallet_service.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  runApp(MyApp(config: config));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final BlockchainService _blockchainService;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _blockchainService = BlockchainService(config: widget.config);
    _authController = AuthController(
      walletService: WalletService(blockchainService: _blockchainService),
      sessionStorage: SessionStorageService(),
      backendApiService: BackendApiService(baseUrl: widget.config.backendUrl),
    );
    _authController.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Voting Mobile',
      home: AuthScreen(authController: _authController),
      routes: {
        VoterHomeScreen.routeName: (context) => VoterHomeScreen(
              blockchainService: _blockchainService,
              authController: _authController,
            ),
        AdminDashboardScreen.routeName: (context) => AdminDashboardScreen(
              config: widget.config,
              blockchainService: _blockchainService,
              authController: _authController,
            ),
        RegisterScreen.routeName: (context) => RegisterScreen(
              authController: _authController,
            ),
      },
    );
  }
}
