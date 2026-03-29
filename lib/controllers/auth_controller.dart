import 'package:flutter/foundation.dart';

import '../services/backend_api_service.dart';
import '../services/session_storage_service.dart';
import '../services/wallet_service.dart';

/// High-level authentication controller managing user login, session, and role.
/// Coordinates WalletService (wallet connection) with SessionStorageService (persistence).
class AuthController extends ChangeNotifier {
  final WalletService walletService;
  final SessionStorageService sessionStorage;
  final BackendApiService backendApiService;

  String? _connectedAccount;
  String _userRole = 'guest'; // 'owner', 'registered_voter', 'pending_voter', 'guest'
  bool _isAuthenticated = false;
  bool _isInitializing = true;
  String? _authError;
  bool _registrationPending = false;
  String? _registrationCid;

  AuthController({
    required this.walletService,
    required this.sessionStorage,
    required this.backendApiService,
  });

  // Getters
  String? get connectedAccount => _connectedAccount;
  String get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitializing => _isInitializing;
  String? get authError => _authError;
  bool get registrationPending => _registrationPending;
  String? get registrationCid => _registrationCid;

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
          _connectedAccount = connected;
          await _evaluateLoginState();
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

  /// Connect wallet only (used by register flow before login).
  Future<String?> connectWalletOnly() async {
    _authError = null;
    try {
      final account = await walletService.connect();
      if (account != null) {
        _connectedAccount = account;
        notifyListeners();
      }
      return account;
    } catch (e) {
      _authError = 'Connection failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Website-style login sequence:
  /// 1) backend /voter/:address
  /// 2) on-chain role detection
  /// 3) local demo linked mapping fallback
  Future<bool> loginWithWallet() async {
    _authError = null;
    if (_connectedAccount == null) {
      final account = await connectWalletOnly();
      if (account == null) {
        return false;
      }
    }

    try {
      await _evaluateLoginState();
      if (_isAuthenticated) {
        final chainId = (await walletService.getChainId()).toString();
        await sessionStorage.saveSession(
          connectedAccount: _connectedAccount!,
          chainId: chainId,
        );
      }

      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _authError = 'Login failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Backward-compatible alias used by existing screens.
  Future<bool> connectWallet() {
    return loginWithWallet();
  }

  Future<void> _evaluateLoginState() async {
    final account = _connectedAccount;
    if (account == null) {
      _isAuthenticated = false;
      _userRole = 'guest';
      _registrationPending = false;
      _registrationCid = null;
      return;
    }

    final backendVoter = await backendApiService.getVoter(account);
    final role = await walletService.detectRole();

    if (role == 'owner') {
      _userRole = 'owner';
      _isAuthenticated = true;
      _registrationPending = false;
      _registrationCid = null;
      return;
    }

    if (role == 'registered_voter') {
      _userRole = 'registered_voter';
      _isAuthenticated = true;
      _registrationPending = false;
      _registrationCid = backendVoter?.cid;
      return;
    }

    if (backendVoter != null ||
        backendApiService.hasLocalDemoWalletLink(account)) {
      _userRole = 'pending_voter';
      _isAuthenticated = true;
      _registrationPending = true;
      _registrationCid = backendVoter?.cid ?? 'local-demo';
      return;
    }

    _isAuthenticated = false;
    _userRole = 'guest';
    _registrationPending = false;
    _registrationCid = null;
    _authError =
        'This wallet is not registered. Complete registration first, then login.';
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
      _registrationPending = false;
      _registrationCid = null;
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
