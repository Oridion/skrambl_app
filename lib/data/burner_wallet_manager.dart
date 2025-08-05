import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';
import '../../data/local_database.dart';

/// created a new file burner_wallet_manager.dart that ties into your Drift setup and Seed Vault auth flow. It:
///	Tracks derivation indices for burner wallets using your existing comets table
/// Automatically derives new keys and stores them with user notes
/// Can also fetch existing burner keys from known indices
class BurnerWalletManager {
  final LocalDatabase db;
  final AuthToken parentToken;

  BurnerWalletManager({required this.db, required this.parentToken});

  /// Creates a new burner wallet by deriving a key at the next unused index.
  /// Returns the encoded public key or null if it failed.
  Future<String?> createBurnerWallet({
    required String note,
    required String destination,
  }) async {
    try {
      final index = await _getNextAvailableIndex();
      final uri = _getDerivationUri(index);

      final result = await SeedVault.instance.requestPublicKeys(
        authToken: parentToken,
        derivationPaths: [uri],
      );

      final publicKey = result.firstOrNull?.publicKeyEncoded;
      if (publicKey == null) return null;

      // Save to comet table
      await db
          .into(db.skrambls)
          .insert(
            SkramblsCompanion(
              id: Value(index),
              note: Value(note),
              status: Value(0),
              createdAt: Value(DateTime.now()),
              destination: Value(destination),
            ),
          );

      return publicKey;
    } catch (e) {
      debugPrint("[BurnerWalletManager] Error creating wallet: $e");
      return null;
    }
  }

  /// Retrieves a public key from a known index
  Future<String?> getBurnerWalletPublicKey(int index) async {
    try {
      final uri = _getDerivationUri(index);
      final result = await SeedVault.instance.requestPublicKeys(
        authToken: parentToken,
        derivationPaths: [uri],
      );
      return result.firstOrNull?.publicKeyEncoded;
    } catch (e) {
      debugPrint(
        "[BurnerWalletManager] Error fetching key for index $index: $e",
      );
      return null;
    }
  }

  /// Gets the next unused derivation index by checking the Drift DB
  Future<int> _getNextAvailableIndex() async {
    final comets = await db.select(db.skrambls).get();
    final usedIndices = comets.map((c) => c.id).toSet();
    for (int i = 1; i < 10000; i++) {
      if (!usedIndices.contains(i)) return i;
    }
    throw Exception("Too many burner wallets created");
  }

  Uri _getDerivationUri(int index) {
    return Bip32DerivationPath.toUri([BipLevel(index: index, hardened: true)]);
  }
}
