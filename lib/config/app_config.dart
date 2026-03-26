enum AppNetwork {
  ganache,
  sepolia,
}

class AppConfig {
  AppConfig({
    required this.network,
    required this.rpcUrl,
    required this.backendUrl,
    required this.contractAddress,
    required this.chainId,
    this.abiAssetPath = 'assets/abi.json',
    this.demoPrivateKey,
  });

  final AppNetwork network;
  final String rpcUrl;
  final String backendUrl;
  final String contractAddress;
  final int chainId;
  final String abiAssetPath;

  // For local development only. Keep unset for normal usage.
  final String? demoPrivateKey;

  static const _networkEnv = String.fromEnvironment(
    'APP_NETWORK',
    defaultValue: 'ganache',
  );

  static const _rpcUrlEnv = String.fromEnvironment('RPC_URL');
  static const _backendUrlEnv = String.fromEnvironment('BACKEND_URL');
  static const _contractAddressEnv = String.fromEnvironment('CONTRACT_ADDRESS');
  static const _chainIdEnv = String.fromEnvironment('CHAIN_ID');
  static const _abiAssetPathEnv = String.fromEnvironment('ABI_ASSET_PATH');
  static const _demoPrivateKeyEnv = String.fromEnvironment('DEMO_PRIVATE_KEY');

  factory AppConfig.fromEnvironment() {
    final network =
        _networkEnv.toLowerCase() == 'sepolia' ? AppNetwork.sepolia : AppNetwork.ganache;

    final defaults = _defaultsFor(network);

    final chainId = int.tryParse(_chainIdEnv) ?? defaults.chainId;
    final abiAssetPath =
        _abiAssetPathEnv.isEmpty ? defaults.abiAssetPath : _abiAssetPathEnv;

    return AppConfig(
      network: network,
      rpcUrl: _rpcUrlEnv.isEmpty ? defaults.rpcUrl : _rpcUrlEnv,
      backendUrl: _backendUrlEnv.isEmpty ? defaults.backendUrl : _backendUrlEnv,
      contractAddress:
          _contractAddressEnv.isEmpty ? defaults.contractAddress : _contractAddressEnv,
      chainId: chainId,
      abiAssetPath: abiAssetPath,
      demoPrivateKey: _demoPrivateKeyEnv.isEmpty ? null : _demoPrivateKeyEnv,
    );
  }

  static AppConfig _defaultsFor(AppNetwork network) {
    switch (network) {
      case AppNetwork.sepolia:
        return AppConfig(
          network: AppNetwork.sepolia,
          rpcUrl: 'https://ethereum-sepolia-rpc.publicnode.com',
          backendUrl: 'https://blockchain-e-voting.onrender.com',
          contractAddress: '0xD08Bbdcb80496e4d53a0Ae769b535306Bb513716',
          chainId: 11155111,
        );
      case AppNetwork.ganache:
        return AppConfig(
          network: AppNetwork.ganache,
          rpcUrl: 'http://10.0.2.2:7545',
          backendUrl: 'http://10.0.2.2:3001',
          contractAddress: '0x0000000000000000000000000000000000000000',
          chainId: 1337,
        );
    }
  }
}
