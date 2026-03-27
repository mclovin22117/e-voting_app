import 'package:flutter/foundation.dart';

import '../services/session_storage_service.dart';
import '../services/wallet_service.dart';

/// High-level authentication controller managing user login, session, and role.
/// Coordinates WalletService (wallet connection) with SessionStorageService (persistence).
class AuthController extends ChangeNotifier {
  final WalletService walletService;
  final SessionStorageService sessionStorage;

  String? _connectedAccount;
  String _userRole = 'guest'; // 'owner', 'registered_voter', 'guest'
  bool _isAuthenticated = false;
  bool _isInitializing = true;
  String? _authError;

  AuthController({
    required this.walletService,
    required this.sessionStorage,
  });

  // Getters
  String? get connectedAccount => _connectedAccount;
  String get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;
  String? get authError => _authError;

  /// Restore session on app startup.
  /// Attempts to reconnect using previously stored session.
  Future<void> restoreSession() async {
    _isInitializing = true;
    _authError = null;
    notifyListeners();

    try {
      final savedSession = await sessionStorage.restoreSession();
      if (savedSession != null) {
        _connectedAccount = savedSession.account;
        // Attempt to re-establish wallet connection
        final connected = await walletService.connect();
        if (connected != null) {
          _isAuthenticated = true;
          _userRole = await walletService.detectRole();
          notifyListeners();
        } else {
          // Session expired or wallet unavailable
          await sessionStorage.clearSession();
          _connectedAccount = null;
          _isAuthenticated = false;
          _userRole = 'guest';
        }
      }
    } catch (e) {
      _authError = 'Failed to restore session: $e';
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Initiate wallet connection.
  /// On success, detects user role and saves session.
  Future<bool> connectWallet() async {
    _authError = null;
    try {
      final account = await walletService.connect();
      if (account != null) {
        _connectedAccount = account;
        _userRole = await walletService.detectRole();
        _isAuthenticated = true;

        // Save session for future app launches
        final chainId = (await walletService.getChainId()).toString();
        await sessionStorage.saveSession(
          connectedAccount: account,
          chainId: chainId,
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _authError = 'Connection failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Disconnect wallet and clear session.
  Future<void> disconnectWallet() async {
    try {
      await walletService.disconnect();
      await sessionStorage.clearSession();
      _connectedAccount = null;
      _userRole = 'guest';
      _isAuthenticated = false;
      _authError = null;
      notifyListeners();
    } catch (e) {
      _authError = 'Disconnect failed: $e';
      notifyListeners();
    }
  }

  /// Check if user can access voter screen.
  bool canAccessVoter() {
    return _isAuthenticated && _userRole != 'owner';
  }

  /// Check if user can access admin screen.
  bool canAccessAdmin() {
    return _isAuthenticated && _userRole == 'owner';
  }
}
