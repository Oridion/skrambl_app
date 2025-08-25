import 'package:collection/collection.dart';
import 'package:skrambl_app/data/burner_dao.dart';
import 'package:solana/solana.dart';
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
  //Cache
  final List<BurnerWallet> _wallets = [];
  List<BurnerWallet> getAllBurners() => List.unmodifiable(_wallets);

  /// Replace the whole cache
  void memoizeAll(List<BurnerWallet> burners) {
    _wallets
      ..clear()
      ..addAll(burners);
  }

  /// Append/replace a single burner (de-dupe by index or pubkey)
  void memoize(BurnerWallet b) {
    final i = _wallets.indexWhere((w) => w.index == b.index || w.publicKey == b.publicKey);
    if (i >= 0) {
      _wallets[i] = b;
    } else {
      _wallets.add(b);
    }
  }

  Future<void> loadBurnersFromDb(BurnerDao dao) async {
    final rows = await dao.getAll(); // DB = source of truth
    final list = rows
        .map((r) => BurnerWallet(index: r.derivationIndex, publicKey: r.pubkey, note: r.note, used: r.used))
        .toList();
    memoizeAll(list);
  }

  // Return the pubkey object
  Future<Ed25519HDPublicKey> derivePublicKeyObj({required AuthToken token, required int accountIndex}) async {
    final pkStr = await ensureBurnerPublicKey(authToken: token, accountIndex: accountIndex);
    return Ed25519HDPublicKey.fromBase58(pkStr);
  }

  // Return the pubkey string
  Future<String> derivePublicKey({required AuthToken token, required int accountIndex}) =>
      ensureBurnerPublicKey(authToken: token, accountIndex: accountIndex);

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
      //skrLogger.i("ERROR");
      throw Exception('Wallet did not return a public key for $resolved');
    }
    //skrLogger.i(pk);
    return pk;
  }

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
