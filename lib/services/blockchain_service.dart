import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {

  final String rpcUrl = "http://10.0.2.2:7545";

  final String privateKey =
      "0x595e05fa70fd6980055415ab854545d7e3f931ef5e05a75fa694d923a8bf1807";

  final String contractAddress =
      "0x491c79f547f83C401B234DfF8E9375E91584717d";

  late Web3Client client;

  BlockchainService() {
    client = Web3Client(rpcUrl, Client());
  }

  Future<DeployedContract> loadContract() async {

    String abiString =
        await rootBundle.loadString(
            "assets/abi.json");

    final contract = DeployedContract(
      ContractAbi.fromJson(
          abiString, "Election"),
      EthereumAddress.fromHex(
          contractAddress),
    );

    return contract;
  }

  // READ function
  Future<List<dynamic>> callFunction(
      String name,
      List<dynamic> args) async {

    final contract = await loadContract();

    final function =
        contract.function(name);

    final result =
        await client.call(
      contract: contract,
      function: function,
      params: args,
    );

    return result;
  }

  // VOTE function
  Future<void> vote(int id) async {

    final contract = await loadContract();

    final function =
        contract.function("vote");

    final credentials =
        EthPrivateKey.fromHex(
            privateKey);

    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          BigInt.from(id)
        ],
      ),
    );
  }

}



