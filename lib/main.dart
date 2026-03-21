lib/main.dart
import 'package:flutter/material.dart';
import 'services/blockchain_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final BlockchainService service = BlockchainService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScaffoldMessenger(
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await service.initialize();
                await service.vote(1);
                print("Vote sent");
              } catch (e) {
                print("Error casting vote: $e");
              }
            },
            child: Text("Vote Candidate 1"),
          ),
        ),
      ),
    );
  }
}