// lib/seed_vault/seed_vault_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skrambl_app/providers/seed_vault_session_manager.dart';
import 'package:solana/solana.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

/// This is the main service class used to interact with the seed vault
/// throughout the application.
class SeedVaultService {
  /// Helper function to always get a valid token.
  /// final token = await getValidToken(context);
  /// if (token == null) return; // User denied
  static Future<AuthToken?> getValidToken(BuildContext context) async {
    final session = Provider.of<SeedVaultSessionManager>(
      context,
      listen: false,
    );
    if (session.authToken != null) return session.authToken;

    final success = await session.requestAuthorization();
    return success ? session.authToken : null;
  }

  static const int defaultIndex = 0;

  /// Get accounts
  static Future getAccounts(AuthToken authToken) async {
    final accounts = await SeedVault.instance.getParsedAccounts(authToken);
    // You can assume these are secure, permissioned, and belong to SKRAMBL's app context.
    return accounts;
  }

  /// Requests permission from user to use Seed Vault
  static Future<bool> requestPermission() async {
    return await SeedVault.instance.checkPermission();
  }

  /// Gets the AuthToken (required for most Seed Vault operations)
  static Future<AuthToken> getAuthToken() async {
    return await SeedVault.instance.authorizeSeed(
      Purpose.signSolanaTransaction,
    );
  }

  /**
    Pros:
      •	Gives you access to the full Account object (not just the public key).
      •	Useful if you want to read metadata like:
      •	accountId
      •	isUserWallet
      •	custom name
      •	Lets you verify if a key is already marked as a user wallet.
      •	Good for apps like SKRAMBL where you might show wallet history or tag accounts.
    Cons:
      •	A bit more verbose.
      •	Slightly more overhead if all you care about is the public key.
   */
  ///getFirstPublicKey(AuthToken) using getParsedAccounts
  Future<String?> getPublicKeyFull(AuthToken token, {int index = 0}) async {
    try {
      final derivationPath = Bip44DerivationPath.toUri([
        const BipLevel(index: 44, hardened: true), // Standard BIP44
        const BipLevel(index: 501, hardened: true), // Solana's coin type
        BipLevel(index: index, hardened: true), // Burner wallet index
      ]);

      final resolvedPath = await SeedVault.instance.resolveDerivationPath(
        derivationPath: derivationPath,
        purpose: Purpose.signSolanaTransaction,
      );

      final accounts = await SeedVault.instance.getParsedAccounts(
        token,
        filter: AccountFilter.byDerivationPath(resolvedPath),
      );

      return accounts.firstOrNull?.publicKeyEncoded;
    } catch (e) {
      debugPrint('Error getting burner public key (index $index): $e');
      return null;
    }
  }

  //Get parent wallet URI
  static Uri getParentWalletUri() {
    return Bip44DerivationPath.toUri([
      BipLevel(index: 44, hardened: true),
      BipLevel(index: 501, hardened: true),
      BipLevel(index: 0, hardened: true),
      BipLevel(index: 0, hardened: true),
    ]);
  }

  /// Derives a single hardened path URI
  static Uri getBurnerWalletUri(int index) {
    return Bip44DerivationPath.toUri([
      BipLevel(index: 44, hardened: true),
      BipLevel(index: 501, hardened: true),
      BipLevel(index: index, hardened: true),
    ]);
  }

  /**
   * Pros:
  •	Faster and lighter: Doesn’t resolve metadata or account info.
	•	Great when you’re just displaying addresses (like a burner wallet list).
	•	Easier to request multiple at once.
	•	Simple and clean if you only want the Base58-encoded public key.
	•	Requires fewer lines and no additional parsing.
	•	Recommended for lightweight key fetching.

Cons:
	•	You don’t get extra parsed data (e.g., name, optional labels, or future metadata).
	•	May not handle advanced filters as flexibly as getParsedAccounts().
	•	Doesn’t give you access to account metadata.
	•	Doesn’t tell you if that path is already being used, marked invalid, or user-tagged.
   */
  /// Requests a single public key using a derived path
  static Future<String?> getPublicKeyString({
    required AuthToken authToken,
    int index = defaultIndex,
  }) async {
    final uri = getBurnerWalletUri(index);
    final result = await SeedVault.instance.requestPublicKeys(
      authToken: authToken,
      derivationPaths: [uri],
    );
    return result.isNotEmpty ? result.first.publicKeyEncoded : null;
  }

  static Future<Ed25519HDPublicKey?> getPublicKey({
    required AuthToken authToken,
    int index = defaultIndex,
  }) async {
    final uri = getBurnerWalletUri(index);

    final result = await SeedVault.instance.requestPublicKeys(
      authToken: authToken,
      derivationPaths: [uri],
    );

    if (result.isEmpty || result.first.publicKeyEncoded == null) {
      throw Exception("❌ No public key returned");
    }

    final encoded = result.first.publicKeyEncoded!;
    return Ed25519HDPublicKey.fromBase58(encoded);
  }

  /// Signs a raw transaction buffer using a derived path

  static Future<Uint8List> signTransaction({
    required Uint8List transactionBytes,
    int index = defaultIndex,
  }) async {
    final authToken = await getAuthToken();
    final uri = getBurnerWalletUri(index);

    final signingRequest = SigningRequest(
      payload: transactionBytes,
      requestedSignatures: [uri],
    );

    final result = await SeedVault.instance.signTransactions(
      authToken: authToken,
      signingRequests: [signingRequest],
    );

    if (result.isEmpty || result.first.signatures.isEmpty) {
      throw Exception("Signing failed or returned empty result");
    }

    return result.first.signatures.first;
  }

  static Future<Uint8List> signMessage({
    required Uint8List messageBytes,
    required AuthToken authToken,
    int index = defaultIndex,
  }) async {
    final uri = getBurnerWalletUri(index);

    final signingRequest = SigningRequest(
      payload: messageBytes,
      requestedSignatures: [uri],
    );

    final result = await SeedVault.instance.signMessages(
      authToken: authToken,
      signingRequests: [signingRequest],
    );

    if (result.isEmpty || result.first.signatures.isEmpty) {
      throw Exception("Message signing failed or returned empty result");
    }

    return result.first.signatures.first;
  }
}

// /// Signed and send base64 message
// Future<String?> signAndSendBase64Message({
//   required String base64Message,
//   required AuthToken authToken,
//   List<int> derivationPath = const [44, 501, 0, 0],
// }) async {
//   try {
//     final messageBytes = base64Decode(base64Message);

//     // 1. Request authorization and get the pubkey (already done earlier)
//     final signedTx = await SeedVault.signTransaction(
//       derivationPath,
//       messageBytes,
//     );

//     // 2. Send to Solana
//     final base64SignedTx = base64Encode(signedTx);

//     final response = await http.post(
//       Uri.parse('https://api.mainnet-beta.solana.com'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         "jsonrpc": "2.0",
//         "id": 1,
//         "method": "sendTransaction",
//         "params": [
//           base64SignedTx,
//           {"encoding": "base64"},
//         ],
//       }),
//     );

//     final json = jsonDecode(response.body);

//     if (json['error'] != null) {
//       skrLogger.e("❌ RPC Error: ${json['error']}");
//       return null;
//     }

//     return json['result']; // This is your tx signature
//   } catch (e) {
//     skrLogger.e("❌ Sign/send failed: $e");
//     return null;
//   }
// }
