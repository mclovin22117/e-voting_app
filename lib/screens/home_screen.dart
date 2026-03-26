import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../services/blockchain_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  final BlockchainService service =
      BlockchainService();

  List<Candidate> candidates = [];

  @override
  void initState() {
    super.initState();
    loadCandidates();
  }

  Future<void> loadCandidates() async {
    final loadedCandidates =
        await service.getCandidates();

    candidates = loadedCandidates;

    setState(() {});
  }

  Future<void> vote(int id) async {
    await service.castVote(id);

    await loadCandidates();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Blockchain Voting"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            const Text(
              "Candidates",
              style:
                  TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 10),

            Expanded(
              child: ListView.builder(

                itemCount:
                    candidates.length,

                itemBuilder:
                    (context, i) {

                  var c =
                      candidates[i];

                  return Card(
                    child: ListTile(

                      title:
                          Text(
                        c.name,
                      ),

                      subtitle:
                          Text(
                        'Votes: ${c.voteCount}',
                      ),

                      trailing:
                          ElevatedButton(

                        onPressed: () =>
                            vote(
                          c.id,
                        ),

                        child:
                            const Text(
                          "Vote",
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed:
                  loadCandidates,
              child:
                  const Text(
                "Refresh",
              ),
            )

          ],
        ),
      ),
    );
  }
}