import 'package:flutter/material.dart';
import 'services/blockchain_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final BlockchainService service =
      BlockchainService();

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("E-Voting App"),
        ),

        body: Center(
          child: ElevatedButton(
            onPressed: () async {

              await service.vote(1);

              print("Vote sent");

            },

            child: Text("Vote Candidate 1"),
          ),
        ),
      ),
    );
  }
}