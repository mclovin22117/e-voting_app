import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'voter_home_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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
              'Choose Journey',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phase 0 baseline routing for authentication and role-based flows.',
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(VoterHomeScreen.routeName);
              },
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Continue as Voter'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AdminDashboardScreen.routeName);
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Continue as Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
