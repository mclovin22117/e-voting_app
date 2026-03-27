/// Manages persistent session storage for user authentication state.
/// Uses Flutter's local storage mechanisms to restore wallet connection
/// across app restarts.
class SessionStorageService {
  static const String _connectedAccountKey = 'wallet_connected_account';
  static const String _sessionDataKey = 'wallet_session_data';

  /// Mock in-memory storage for demo purposes.
  /// In production, this would use SharedPreferences or Hive.
  final Map<String, String> _storage = {};

  /// Save the current wallet session to persistent storage.
  Future<void> saveSession({
    required String connectedAccount,
    required String chainId,
  }) async {
    _storage[_connectedAccountKey] = connectedAccount;
    _storage[_sessionDataKey] = _encodeSessionData(
      account: connectedAccount,
      chainId: chainId,
    );
    // In production, persist to actual storage system
  }

  /// Restore wallet session from persistent storage.
  /// Returns null if no session exists.
  Future<WalletSession?> restoreSession() async {
    final account = _storage[_connectedAccountKey];
    if (account == null) return null;

    final sessionData = _storage[_sessionDataKey];
    if (sessionData == null) return null;

    return _decodeSessionData(sessionData);
  }

  /// Clear the stored session (logout).
  Future<void> clearSession() async {
    _storage.remove(_connectedAccountKey);
    _storage.remove(_sessionDataKey);
    // In production, remove from actual storage system
  }

  /// Check if a session exists without loading it.
  Future<bool> hasExistingSession() async {
    return _storage.containsKey(_connectedAccountKey);
  }

  String _encodeSessionData({
    required String account,
    required String chainId,
  }) {
    return '$account:$chainId';
  }

  WalletSession? _decodeSessionData(String data) {
    try {
      final parts = data.split(':');
      if (parts.length != 2) return null;
      return WalletSession(
        account: parts[0],
        chainId: parts[1],
      );
    } catch (e) {
      return null;
    }
  }
}

/// Represents a restored wallet session.
class WalletSession {
  final String account;
  final String chainId;

  WalletSession({
    required this.account,
    required this.chainId,
  });
}
