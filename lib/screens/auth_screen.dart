import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'admin_dashboard_screen.dart';
import 'voter_home_screen.dart';

class AuthScreen extends StatelessWidget {
  final AuthController authController;

  const AuthScreen({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Voting Mobile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Wallet Authentication',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect your wallet to participate in voting or manage elections.',
            ),
            const SizedBox(height: 24),
            // Connection status
            if (authController.isInitializing)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (authController.connectedAccount != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Wallet Connected',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Account: ${authController.connectedAccount!.substring(0, 10)}...${authController.connectedAccount!.substring(authController.connectedAccount!.length - 8)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Role: ${authController.userRole}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Not Connected',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            if (authController.authError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authController.authError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Action buttons
            if (!authController.isAuthenticated)
              ElevatedButton.icon(
                onPressed: () async {
                  final connected = await authController.connectWallet();
                  if (connected && context.mounted) {
                    // Role-based navigation
                    if (authController.canAccessAdmin()) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                        AdminDashboardScreen.routeName,
                        (route) => false,
                      )
                          .ignore();
                    } else if (authController.canAccessVoter()) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                        VoterHomeScreen.routeName,
                        (route) => false,
                      )
                          .ignore();
                    }
                  }
                },
                icon: const Icon(Icons.wallet),
                label: const Text('Connect Wallet'),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: () {
                  if (authController.canAccessVoter()) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      VoterHomeScreen.routeName,
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.how_to_vote),
                label: const Text('Go to Voter Dashboard'),
              ),
              const SizedBox(height: 12),
              if (authController.canAccessAdmin())
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AdminDashboardScreen.routeName,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Go to Admin Dashboard'),
                )
              else
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Admin Access Denied'),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await authController.disconnectWallet();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Disconnect'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
