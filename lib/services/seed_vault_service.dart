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
  //Resolve the derivation path
  static Future<Uri> resolvePathForIndex({required int index, required Purpose purpose}) async {
    final raw = getWalletUri(index);
    return SeedVault.instance.resolveDerivationPath(derivationPath: raw, purpose: purpose);
  }

  // Expose and get the publick key at index (for burner wallet)
  static Future<String> exposeAndGetPubkeyAtIndex({required AuthToken authToken, required int index}) async {
    final resolved = await resolvePathForIndex(index: index, purpose: Purpose.signSolanaTransaction);
    final res = await SeedVault.instance.requestPublicKeys(authToken: authToken, derivationPaths: [resolved]);
    final pk = res.first.publicKeyEncoded;
    if (pk == null) {
      throw Exception('No public key returned for $resolved');
    }
    return pk;
  }

  // Explicitly sign a single message with a specific resolved derivation path
  static Future<Uint8List> signMessageWithResolvedPath({
    required AuthToken authToken,
    required Uint8List messageBytes,
    required Uri resolvedPath,
  }) async {
    final req = SigningRequest(payload: messageBytes, requestedSignatures: [resolvedPath]);
    final out = await SeedVault.instance.signMessages(authToken: authToken, signingRequests: [req]);
    final sig = out.first.signatures.firstOrNull;
    if (sig == null || sig.length != 64) {
      throw Exception('Invalid signature from Seed Vault');
    }
    return sig;
  }

  /// Helper function to always get a valid token.
  /// final token = await getValidToken(context);
  /// if (token == null) return; // User denied
  static Future<AuthToken?> getValidToken(BuildContext context) async {
    final session = Provider.of<SeedVaultSessionManager>(context, listen: false);
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
    return await SeedVault.instance.authorizeSeed(Purpose.signSolanaTransaction);
  }

  /// Derives a single hardened path URI
  static Uri getWalletUri(int index) {
    return Bip44DerivationPath.toUri([
      BipLevel(index: 44, hardened: true),
      BipLevel(index: 501, hardened: true),
      BipLevel(index: index, hardened: true),
    ]);
  }

  /// Requests a single public key using a derived path
  static Future<String?> getPublicKeyString({required AuthToken authToken, int index = defaultIndex}) async {
    final uri = getWalletUri(index);
    final result = await SeedVault.instance.requestPublicKeys(authToken: authToken, derivationPaths: [uri]);
    return result.isNotEmpty ? result.first.publicKeyEncoded : null;
  }

  static Future<Ed25519HDPublicKey?> getPublicKey({
    required AuthToken authToken,
    int index = defaultIndex,
  }) async {
    final uri = getWalletUri(index);
    final result = await SeedVault.instance.requestPublicKeys(authToken: authToken, derivationPaths: [uri]);
    if (result.isEmpty || result.first.publicKeyEncoded == null) {
      throw Exception("❌ No public key returned");
    }
    final encoded = result.first.publicKeyEncoded!;
    return Ed25519HDPublicKey.fromBase58(encoded);
  }

  static Future<Uint8List> signMessage({
    required Uint8List messageBytes,
    required AuthToken authToken,
    int index = defaultIndex,
  }) async {
    final uri = getWalletUri(index);

    final signingRequest = SigningRequest(payload: messageBytes, requestedSignatures: [uri]);

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
