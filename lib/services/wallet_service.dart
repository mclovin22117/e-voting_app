import 'package:web3dart/web3dart.dart';

import 'blockchain_service.dart';

/// Service for managing wallet connections and signing transactions.
/// Supports both WalletConnect (production) and demo signing (local development).
class WalletService {
  final BlockchainService blockchainService;

  String? _connectedAccount;
  bool _isConnected = false;
  bool _isConnecting = false;

  WalletService({required this.blockchainService});

  /// Get the currently connected account address.
  String? get connectedAccount => _connectedAccount;

  /// Check if wallet is connected.
  bool get isConnected => _isConnected;

  /// Check if wallet connection is in progress.
  bool get isConnecting => _isConnecting;

  /// Initiate wallet connection.
  /// In production, this would launch WalletConnect modal.
  /// For demo/test, uses configured demo account if DEMO_PRIVATE_KEY is set.
  Future<String?> connect() async {
    _isConnecting = true;
    try {
      // Demo mode: use configured demo account for local development
      if (blockchainService.config.demoPrivateKey != null) {
        final credentials =
            EthPrivateKey.fromHex(blockchainService.config.demoPrivateKey!);
        _connectedAccount = credentials.address.hexEip55;
        _isConnected = true;
        return _connectedAccount;
      }

      // Production mode: would use WalletConnect v2
      // For now, return null until WalletConnect is fully integrated
      _isConnected = false;
      return null;
    } catch (e) {
      _isConnected = false;
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect the wallet session.
  Future<void> disconnect() async {
    _connectedAccount = null;
    _isConnected = false;
  }

  /// Sign a message with the connected wallet.
  /// Requires wallet to be connected first.
  Future<String> signMessage(String message) async {
    if (!_isConnected || _connectedAccount == null) {
      throw Exception('Wallet not connected. Call connect() first.');
    }

    // Demo mode: use local key signing (not secure, dev only)
    if (blockchainService.config.demoPrivateKey != null) {
      try {
        // In production, would use proper message signing (EIP-191)
        // For demo, just return a mock signature
        return '0x${message.codeUnits.map((e) => e.toRadixString(16)).join()}';
      } catch (e) {
        throw Exception('Failed to sign message: $e');
      }
    }

    // Production mode: signature would come from WalletConnect
    throw Exception('WalletConnect signing not yet implemented');
  }

  /// Get the chain ID currently configured for the connected wallet.
  Future<int> getChainId() async {
    return blockchainService.config.chainId;
  }

  /// Determine the user's role based on blockchain state.
  /// Returns: 'owner', 'registered_voter', or 'guest'
  Future<String> detectRole() async {
    if (!_isConnected || _connectedAccount == null) {
      return 'guest';
    }

    try {
      // Check if connected account is the owner
      final owner = await blockchainService.getOwnerAddress();
      if (owner.hexEip55.toLowerCase() == _connectedAccount!.toLowerCase()) {
        return 'owner';
      }

      // Check if account is registered as a voter
      final isRegistered =
          await blockchainService.isRegistered(_connectedAccount!);
      if (isRegistered) {
        return 'registered_voter';
      }

      return 'guest';
    } catch (e) {
      return 'guest';
    }
  }
}
