import 'package:flutter/foundation.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

/// General usage for all activities throughout app.
// ignore: unintended_html_in_doc_comment
///final session = Provider.of<SeedVaultSessionManager>(context, listen: false);
// final token = session.authToken;
// if (token == null) {
//   final success = await session.requestAuthorization();
//   if (!success) {
//     // Show error or handle rejection
//     return;
//   }
// }
// Now safe to use session.authToken for public key/signing/etc.

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

    _isAvailable = await SeedVault.instance.isAvailable(allowSimulated: true);
    if (_isAvailable) {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _hasPermission = await SeedVault.instance.checkPermission();

    skrLogger.i('SeedVault isAvailable: $_isAvailable');
    skrLogger.i('SeedVault has permission: $_hasPermission');

    if (!_isAvailable || !_hasPermission) {
      _authToken = null;
      notifyListeners();
      return;
    }

    try {
      final authorizedSeeds = await SeedVault.instance.getAuthorizedSeeds();
      if (authorizedSeeds.isNotEmpty) {
        final seed = authorizedSeeds.first;
        final token =
            seed[WalletContractV1.authorizedSeedsAuthToken] as AuthToken?;
        if (token != null) {
          skrLogger.i("✅ Restoring token from seed: $token");
          _authToken = token;
          await validateToken(); // Only if token exists
        }
      } else {
        skrLogger.w(
          '⚠️ No authorized seeds yet — waiting for user to authorize.',
        );
        _authToken = null; // Don't request inside init — do that manually in UI
      }
    } catch (e) {
      skrLogger.e('SeedVault init error: $e');
      _authToken = null;
    }

    notifyListeners();
  }

  void setAuthToken(AuthToken token) {
    _authToken = token;
    notifyListeners();
  }

  /// Manually prompt for authorization (e.g., on user action)
  Future<bool> requestAuthorization() async {
    try {
      _authToken = await SeedVault.instance.authorizeSeed(
        Purpose.signSolanaTransaction,
      );
      _hasPermission = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Authorization failed: $e');
      _authToken = null;
      _hasPermission = false;
      notifyListeners();
      return false;
    }
  }

  ///Call before any action to make sure the token is valid.
  Future<bool> validateToken() async {
    if (_authToken == null) return false;

    try {
      // Try a lightweight call to check validity
      await SeedVault.instance.getAccounts(authToken: _authToken!);
      skrLogger.i("AuthToken VALID");
      return true;
    } catch (e) {
      debugPrint("Token validation failed: $e");
      _authToken = null;
      _hasPermission = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear current session (e.g., on logout or error)
  void reset() {
    _authToken = null;
    _hasPermission = false;
    notifyListeners();
  }
}
