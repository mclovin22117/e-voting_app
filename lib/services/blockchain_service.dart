import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  final String rpcUrl = "http://10.0.2.2:7545";
  final String privateKey =
      "YOUR_PRIVATE_KEY";

  late Web3Client client;

  BlockchainService() {
    client = Web3Client(rpcUrl, Client());
  }

  Future<void> getBalance() async {
    final credentials =
        EthPrivateKey.fromHex(privateKey);

    final address = credentials.address;

    final balance =
        await client.getBalance(address);

    print(balance.getInEther);
  }
}