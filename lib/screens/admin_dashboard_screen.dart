import 'package:flutter/material.dart';

import '../config/app_config.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
    required this.config,
  });

  static const routeName = '/admin';

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phase 0 Baseline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Admin controls will be added in Phase 4.'),
            const SizedBox(height: 20),
            Text('Network: ${config.network.name}'),
            Text('Chain ID: ${config.chainId}'),
            Text('Contract: ${config.contractAddress}'),
          ],
        ),
      ),
    );
  }
}
