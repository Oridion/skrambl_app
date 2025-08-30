import 'package:flutter/material.dart';
import 'package:skrambl_app/services/seed_vault_service.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class SeedVaultSessionManager extends ChangeNotifier {
  bool _isInitializing = false;
  bool _isAvailable = false;
  bool _hasPermission = false;
  AuthToken? _authToken;

  bool get isAvailable => _isAvailable;
  bool get hasPermission => _hasPermission;
  AuthToken? get authToken => _authToken;

  /// Initialize on app start
  Future<void> initialize() async {
    if (_isInitializing) return;
    _isInitializing = true;
    bool changed = false;

    try {
      final avail = await SeedVault.instance.isAvailable(allowSimulated: true);
      if (_isAvailable != avail) {
        _isAvailable = avail;
        changed = true;
      }

      if (_isAvailable) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final perm = await SeedVault.instance.checkPermission();
      if (_hasPermission != perm) {
        _hasPermission = perm;
        changed = true;
      }

      skrLogger.i('SeedVault isAvailable: $_isAvailable');
      skrLogger.i('SeedVault has permission: $_hasPermission');

      if (!_isAvailable || !_hasPermission) {
        if (_authToken != null) {
          _authToken = null;
          changed = true;
        }
        if (changed) notifyListeners();
        return;
      }

      try {
        final authorizedSeeds = await SeedVault.instance.getAuthorizedSeeds();
        if (authorizedSeeds.isNotEmpty) {
          final seed = authorizedSeeds.first;
          final token = seed[WalletContractV1.authorizedSeedsAuthToken] as AuthToken?;
          if (token != null && token != _authToken) {
            _authToken = token;
            changed = true;
            skrLogger.i("Restoring token from seed: $token");
            // Don’t throw away permission if token is invalid; just clear token.
            final ok = await validateToken();
            if (!ok) {
              changed = true;
            }
          }
        } else {
          skrLogger.w('No authorized seeds yet — waiting for user to authorize.');
          if (_authToken != null) {
            _authToken = null;
            changed = true;
          }
        }
      } catch (e) {
        skrLogger.e('SeedVault init error: $e');
        if (_authToken != null) {
          _authToken = null;
          changed = true;
        }
      }

      if (changed) notifyListeners();
    } finally {
      _isInitializing = false; // <-- critical
    }
  }

  /// Always returns a valid token, re-requesting if necessary
  /// Not to be confused with seedVaultService.getValidToken.
  Future<AuthToken?> getValidTokenFromManager(BuildContext context) async {
    final isAvailable = await SeedVault.instance.isAvailable(allowSimulated: true);
    if (!isAvailable) throw Exception("Seed Vault not available");

    final permissionGranted = await SeedVaultService.requestPermission();
    if (!permissionGranted) throw Exception("Seed Vault permission denied");

    if (!context.mounted) return null;
    final token = await SeedVaultService.getValidToken(context);
    if (token == null) {
      skrLogger.e("❌ Seed Vault authorization denied.");
      return null;
    }
    _authToken = token;
    return token;
  }

  void setAuthToken(AuthToken token) {
    if (_authToken == token) return;
    _authToken = token;
    notifyListeners();
  }

  /// Manually prompt for authorization (e.g., on user action)
  Future<bool> requestAuthorization() async {
    try {
      final token = await SeedVault.instance.authorizeSeed(Purpose.signSolanaTransaction);
      _authToken = token;
      _hasPermission = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Authorization failed: $e');
      _authToken = null;
      // Don’t assume permission revoked; re-check:
      _hasPermission = await SeedVault.instance.checkPermission();
      notifyListeners();
      return false;
    }
  }

  ///Call before any action to make sure the token is valid.
  Future<bool> validateToken() async {
    final token = _authToken;
    if (token == null) return false;
    try {
      await SeedVault.instance.getAccounts(authToken: token);
      skrLogger.i("AuthToken VALID");
      return true;
    } catch (e) {
      debugPrint("Token validation failed: $e");
      _authToken = null;
      // Re-check permission; token invalid != permission revoked
      _hasPermission = await SeedVault.instance.checkPermission();
      notifyListeners();
      return false;
    }
  }

  /// Convenience: ensure you have a valid token, trying init → validate → request if needed.
  Future<AuthToken?> ensureValidToken(BuildContext context) async {
    await initialize(); // will no-op if already init’d, thanks to guard+finally
    if (await validateToken()) {
      // existing token good?
      return _authToken;
    }
    return getValidTokenFromManager(context); // interactive path
  }

  /// Clear current session (e.g., on logout or error)
  void reset() {
    _authToken = null;
    notifyListeners();
  }
}
