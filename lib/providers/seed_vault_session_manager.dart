import 'package:flutter/foundation.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

/// General usage for all activities throughout app.
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
    //Stop initialize loops
    if (_isInitializing) return;
    _isInitializing = true;

    _isAvailable = await SeedVault.instance.isAvailable(allowSimulated: true);
    _hasPermission = await SeedVault.instance.checkPermission();

    skrLogger.i('SeedVault isAvailable: $_isAvailable');
    skrLogger.i('SeedVault has permission: $_hasPermission');

    if (!_isAvailable || !_hasPermission) {
      _authToken = null;
      notifyListeners();
      return;
    }

    // 🔥 Restore existing authorized seed session
    try {
      final authorizedSeeds = await SeedVault.instance.getAuthorizedSeeds();
      if (authorizedSeeds.isNotEmpty) {
        skrLogger.i("Authorized seeds found. Resetting.. ");
        final seed = authorizedSeeds.first;
        _authToken =
            seed[WalletContractV1.authorizedSeedsAuthToken] as AuthToken;
        skrLogger.i(
          '✅ Restored authToken from existing authorized seed. $_authToken',
        );

        skrLogger.i(seed);

        // final account = await SeedVault.instance.getAccount(
        //   authToken: _authToken as int,
        //   id: 0,
        // );

        // skrLogger.i(account);

        validateToken();
      } else {
        skrLogger.w('⚠️ No authorized seeds found. Requesting authorization');
        await requestAuthorization();
        _authToken = null;
      }
    } catch (e) {
      skrLogger.e('Failed to restore authorized seed: $e');
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
