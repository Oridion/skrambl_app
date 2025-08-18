import 'package:skrambl_app/services/burner_wallet_management.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/data/local_database.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

/// Repository = orchestration layer between Seed Vault (manager) and Drift (dao).
class BurnerRepository {
  final BurnerWalletManager manager;
  final BurnerDao dao;

  BurnerRepository({required this.manager, required this.dao});

  /// Create a new burner key (derives from Seed Vault), then persist it in DB.
  /// Returns the in-memory BurnerWallet (index + publicKey + optional note).
  Future<BurnerWallet?> createBurner({required AuthToken token, String? note}) async {
    final index = await manager.allocateNextIndex();
    final wallet = await manager.createBurnerWallet(token: token, index: index, note: note);
    if (wallet == null) return null;
    await dao.upsertBurner(pubkey: wallet.publicKey, derivationIndex: index, note: note);
    return wallet;
  }

  /// Restore manager’s in-memory cache from DB (useful on cold start).
  Future<void> warmCacheFromDb({required AuthToken token}) async {
    final rows = await dao.getAll();
    final indices = rows.map((b) => b.derivationIndex).toList();
    await manager.restoreByIndices(token: token, indices: indices);
  }

  /// Stream the active burners (archived=false), newest used first.
  Stream<List<Burner>> watchAllActive() => dao.watchAllActive();

  /// One-off lookups and mutations
  Future<Burner?> getByPubkey(String pubkey) => dao.getByPubkey(pubkey);

  Future<void> setNote(String pubkey, String? note) async {
    await dao.setNote(pubkey, note);
  }

  Future<void> archive(String pubkey, {bool archived = true}) async {
    await dao.archive(pubkey, archived: archived);
  }

  /// Mark a burner as used (sets used=true and lastUsedAt=now).
  Future<void> markUsed(String pubkey) async {
    await dao.markUsed(pubkey: pubkey, used: true);
  }

  /// Call this after a successful send from this burner:
  /// increments tx_count, sets used=true, updates last_used_at.
  Future<void> bumpTxCountAfterSend(String pubkey) async {
    await dao.bumpTxCountAndTouch(pubkey: pubkey);
  }

  /// Optional: touch lastSeenAt (e.g., after refreshing balance for this burner).
  Future<void> touchSeen(String pubkey) => dao.touchSeen(pubkey);

  Future<List<BurnerWallet>> fetchBurners() async {
    // If you later persist to Drift, read from DB here instead of manager memory.
    return manager.getAllBurners();
  }

  // Future<BurnerWallet> createBurner(String label) async {
  //   final next = manager.getNextIndex();
  //   final created = await manager.createBurnerWallet(index: next, note: label);
  //   if (created == null) {
  //     throw Exception('Failed to create burner wallet via Seed Vault.');
  //   }
  //   return created;
  // }
}
