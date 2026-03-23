import 'package:flutter/material.dart';
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

  List candidates = [];

  @override
  void initState() {
    super.initState();
    loadCandidates();
  }

  Future<void> loadCandidates() async {

    candidates.clear();

    int count =
        await service.getCandidatesCount();

    for (int i = 1; i <= count; i++) {

      var c =
          await service.getCandidate(i);

      candidates.add({
        "id":
            (c[0] as BigInt).toInt(),
        "name":
            c[1],
        "votes":
            (c[2] as BigInt).toInt(),
      });
    }

    setState(() {});
  }

  Future<void> vote(int id) async {

    await service.vote(id);

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
                        c["name"],
                      ),

                      subtitle:
                          Text(
                        "Votes: ${c["votes"]}",
                      ),

                      trailing:
                          ElevatedButton(

                        onPressed: () =>
                            vote(
                          c["id"],
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