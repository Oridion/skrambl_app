import 'package:collection/collection.dart';
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
    required AuthToken token,
    required int index,
    String? note,
  }) async {
    try {
      final derivationPath = Bip44DerivationPath.toUri([
        BipLevel(index: index, hardened: true),
        BipLevel(index: 0, hardened: true),
        BipLevel(index: 0, hardened: true),
      ]);

      final resolvedPath = await SeedVault.instance.resolveDerivationPath(
        derivationPath: derivationPath,
        purpose: Purpose.signSolanaTransaction,
      );

      final accounts = await SeedVault.instance.getParsedAccounts(
        token,
        filter: AccountFilter.byDerivationPath(resolvedPath),
      );

      final pk = accounts.firstOrNull?.publicKeyEncoded;
      if (pk == null) return null;

      final w = BurnerWallet(index: index, publicKey: pk, note: note);
      if (_wallets.indexWhere((x) => x.index == index) == -1) _wallets.add(w);
      return w;
    } catch (_) {
      return null;
    }
  }

  /// Rebuild a list of burners by indices (e.g., after reading indices from DB)
  /// Probably not needed.
  Future<List<BurnerWallet>> restoreByIndices({required AuthToken token, required List<int> indices}) async {
    final out = <BurnerWallet>[];
    for (final i in indices.toSet()..removeWhere((x) => x < 0)) {
      final w = await createBurnerWallet(token: token, index: i);
      if (w != null) out.add(w);
    }
    return out;
  }

  /// Naive next free index (guarded against double-taps)
  Future<int> allocateNextIndex() async {
    if (_allocating) await Future.delayed(const Duration(milliseconds: 150));
    _allocating = true;
    try {
      final used = _wallets.map((w) => w.index).toSet();
      var next = 0;
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
