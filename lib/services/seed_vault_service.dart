// lib/seed_vault/seed_vault_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solana/solana.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

import 'package:skrambl_app/providers/seed_vault_session_manager.dart';

class SeedVaultService {
  static const int defaultIndex = 0;

  // --- Core builders ---------------------------------------------------------

  /// BIP-44 (3 segments ONLY): bip44:/44'/501'/{account}'
  static Uri _bip44AccountUri(int account) => Bip44DerivationPath.toUri([
    BipLevel(index: 44, hardened: true),
    BipLevel(index: 501, hardened: true),
    BipLevel(index: account, hardened: true),
  ]);

  static void assertBip44Has3Segments(Uri u) {
    // Expect: scheme 'bip44', path like "/44'/501'/{account}'"
    final path = u.path; // e.g. "/44'/501'/0'"
    final segs = path.split('/').where((s) => s.isNotEmpty).toList();
    assert(u.scheme == 'bip44', 'Expected bip44, got ${u.scheme}');
    assert(segs.length == 3, 'Expected 3 segments, got ${segs.length}: $path');
  }

  static Future<Uri> _resolve({required int accountIndex, required Purpose purpose}) {
    final raw = _bip44AccountUri(accountIndex);
    // TEMP: log + assert
    // ignore: avoid_print
    print('[SV] resolve IN  : $raw');
    assertBip44Has3Segments(raw);
    return SeedVault.instance.resolveDerivationPath(derivationPath: raw, purpose: purpose).then((u) {
      // ignore: avoid_print
      print('[SV] resolve OUT : $u'); // should be bip32:/m/44'/501'/{acct}'/0'
      return u;
    });
  }

  // --- Auth helpers ----------------------------------------------------------

  static Future<bool> requestPermission() => SeedVault.instance.checkPermission();

  static Future<AuthToken> getAuthToken() => SeedVault.instance.authorizeSeed(Purpose.signSolanaTransaction);

  static Future<AuthToken?> getValidToken(BuildContext context) async {
    final session = Provider.of<SeedVaultSessionManager>(context, listen: false);
    if (session.authToken != null) return session.authToken;
    final ok = await session.requestAuthorization();
    return ok ? session.authToken : null;
  }

  static Future<AuthToken> reauthorize() => SeedVault.instance.authorizeSeed(Purpose.signSolanaTransaction);

  // --- Account discovery -----------------------------------------------------

  static Future getAccounts(AuthToken token) => SeedVault.instance.getParsedAccounts(token);

  /// Get public key (primary = account 0) via **resolved** path.
  static Future<Ed25519HDPublicKey> getPublicKey({
    required AuthToken authToken,
    int accountIndex = defaultIndex,
  }) async {
    final resolved = await _resolve(accountIndex: accountIndex, purpose: Purpose.signSolanaTransaction);
    final res = await SeedVault.instance.requestPublicKeys(authToken: authToken, derivationPaths: [resolved]);
    final pk = res.first.publicKeyEncoded ?? (throw Exception('No public key returned for $resolved'));
    return Ed25519HDPublicKey.fromBase58(pk);
  }

  /// Convenience (string form).
  static Future<String?> getPublicKeyString({
    required AuthToken authToken,
    int accountIndex = defaultIndex,
  }) async {
    final resolved = await _resolve(accountIndex: accountIndex, purpose: Purpose.signSolanaTransaction);
    final res = await SeedVault.instance.requestPublicKeys(authToken: authToken, derivationPaths: [resolved]);
    return res.isNotEmpty ? res.first.publicKeyEncoded : null;
  }

  /// Burner flow: expose + get pubkey at a specific account index (still resolved).
  static Future<String> exposeAndGetPubkeyAtIndex({required AuthToken authToken, required int index}) async {
    final resolved = await _resolve(accountIndex: index, purpose: Purpose.signSolanaTransaction);
    final res = await SeedVault.instance.requestPublicKeys(authToken: authToken, derivationPaths: [resolved]);
    final pk = res.first.publicKeyEncoded;
    if (pk == null) throw Exception('No public key returned for $resolved');
    return pk;
  }

  // --- Signing ---------------------------------------------------------------

  /// Sign using the **resolved** canonical path.
  static Future<Uint8List> signMessage({
    required AuthToken authToken,
    required Uint8List messageBytes,
    int accountIndex = defaultIndex,
  }) async {
    final resolved = await _resolve(accountIndex: accountIndex, purpose: Purpose.signSolanaTransaction);
    final req = SigningRequest(payload: messageBytes, requestedSignatures: [resolved]);
    final out = await SeedVault.instance.signMessages(authToken: authToken, signingRequests: [req]);
    final sig = out.first.signatures.firstOrNull;
    if (sig == null || sig.length != 64) {
      throw Exception('Invalid signature from Seed Vault');
    }
    return sig;
  }

  /// If you already have a **resolved** path from elsewhere, use this.
  static Future<Uint8List> signMessageWithResolvedPath({
    required AuthToken authToken,
    required Uint8List messageBytes,
    required Uri resolvedPath,
  }) async {
    final req = SigningRequest(payload: messageBytes, requestedSignatures: [resolvedPath]);
    final out = await SeedVault.instance.signMessages(authToken: authToken, signingRequests: [req]);
    final sig = out.first.signatures.firstOrNull;
    if (sig == null || sig.length != 64) throw Exception('Invalid signature');
    return sig;
  }
}
