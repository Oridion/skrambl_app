import 'package:collection/collection.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:skrambl_app/utils/logger.dart';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class BurnerWallet {
  final int index;
  final String publicKey;
  final String? note;
  final bool used;

  const BurnerWallet({required this.index, required this.publicKey, this.note, this.used = false});

  BurnerWallet copyWith({String? note, bool? used}) =>
      BurnerWallet(index: index, publicKey: publicKey, note: note ?? this.note, used: used ?? this.used);
}

/// Stateless w.r.t. auth — fetches a fresh token via the injected callback
class BurnerWalletManager {
  final List<BurnerWallet> _wallets = [];
  bool _allocating = false;

  /// Derive / resolve a burner at `index`. Optionally attach a local `note`.
  Future<BurnerWallet?> createBurnerWallet({
    required BurnerDao dao,
    required AuthToken token,
    required int index,
    String? note,
  }) async {
    skrLogger.i("index: $index");

    // try {
    //   final derivationPath = Bip44DerivationPath.toUri([
    //     const BipLevel(index: 44, hardened: true), // Standard BIP44
    //     const BipLevel(index: 501, hardened: true), // Solana's coin type
    //     BipLevel(index: index, hardened: true), // Burner wallet index
    //   ]);

    //   skrLogger.i("path: $derivationPath");

    //   final resolvedPath = await SeedVault.instance.resolveDerivationPath(
    //     derivationPath: derivationPath,
    //     purpose: Purpose.signSolanaTransaction,
    //   );

    //   final accounts = await SeedVault.instance.getParsedAccounts(
    //     token,
    //     filter: AccountFilter.byDerivationPath(resolvedPath),
    //   );

    //   final pk = accounts.firstOrNull?.publicKeyEncoded;

    //   skrLogger.i("HERE");
    //   skrLogger.i(pk);

    //   if (pk == null) return null;

    //   final w = BurnerWallet(index: index, publicKey: pk, note: note);
    //   if (_wallets.indexWhere((x) => x.index == index) == -1) _wallets.add(w);
    //   return w;
    // } catch (e) {
    //   skrLogger.i("FAILED HERE: $e");
    //   return null;
    // }
    final pubkey = await ensureBurnerPublicKey(authToken: token, accountIndex: index);

    // Keep your in-memory list in sync (optional)
    // manager.memoize(BurnerWallet(index: index, publicKey: pubkey, note: note));

    // Persist in Drift so it shows in UI
    await dao.upsertBurner(pubkey: pubkey, derivationIndex: index, note: note);
    return BurnerWallet(index: index, publicKey: pubkey, note: note);
  }

  /// Returns the public key at m/44'/501'/accountIndex', creating the account if missing.
  Future<String> ensureBurnerPublicKey({required AuthToken authToken, required int accountIndex}) async {
    // 1) Resolve the path for the Solana signing purpose
    final derivationPath = Bip44DerivationPath.toUri([
      const BipLevel(index: 44, hardened: true), // Standard BIP44
      const BipLevel(index: 501, hardened: true), // Solana's coin type
      BipLevel(index: accountIndex, hardened: true), // Burner wallet index
    ]);
    final resolved = await SeedVault.instance.resolveDerivationPath(
      derivationPath: derivationPath,
      purpose: Purpose.signSolanaTransaction,
    );

    // 2) Ask the wallet to provide (and if needed, create/expose) the public key
    final responses = await SeedVault.instance.requestPublicKeys(
      authToken: authToken,
      derivationPaths: [resolved],
    );

    final pk = responses.firstOrNull?.publicKeyEncoded;
    if (pk == null) {
      skrLogger.i("ERROR");
      throw Exception('Wallet did not return a public key for $resolved');
    }
    skrLogger.i(pk);
    return pk;
  }

  /// Rebuild a list of burners by indices (e.g., after reading indices from DB)
  /// Probably not needed.
  Future<List<BurnerWallet>> restoreByIndices({
    required BurnerDao dao,
    required AuthToken token,
    required List<int> indices,
  }) async {
    final out = <BurnerWallet>[];
    for (final i in indices.toSet()..removeWhere((x) => x < 0)) {
      final w = await createBurnerWallet(dao: dao, token: token, index: i);
      if (w != null) out.add(w);
    }
    return out;
  }

  /// Naive next free index (guarded against double-taps)
  /// Starts from 100 for burners
  Future<int> allocateNextIndex() async {
    if (_allocating) await Future.delayed(const Duration(milliseconds: 150));
    _allocating = true;
    try {
      final used = _wallets.map((w) => w.index).toSet();
      var next = 100;
      while (used.contains(next)) {
        next++;
      }
      return next;
    } finally {
      _allocating = false;
    }
  }

  List<BurnerWallet> getAllBurners() => List.unmodifiable(_wallets);

  int getNextIndex() {
    if (_wallets.isEmpty) return 0;
    final used = _wallets.map((w) => w.index).toSet();
    var next = 0;
    while (used.contains(next)) {
      next++;
    }
    return next;
    // (kept for compatibility; allocateNextIndex() is the async/guarded version)
  }

  void markUsed(int index) {
    final idx = _wallets.indexWhere((w) => w.index == index);
    if (idx != -1) {
      _wallets[idx] = _wallets[idx].copyWith(used: true);
    }
  }
}
