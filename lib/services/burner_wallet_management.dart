import 'package:solana_seed_vault/solana_seed_vault.dart';
import 'package:collection/collection.dart';

///	Tracks the current index
///	Creates a new burner key
///	Lists previously used keys
///	Restores existing burners using saved indices

class BurnerWallet {
  final int index;
  final String publicKey;
  final String? note;
  final bool used;

  BurnerWallet({
    required this.index,
    required this.publicKey,
    this.note,
    this.used = false,
  });
}

class BurnerWalletManager {
  final AuthToken authToken;
  final List<BurnerWallet> _wallets = [];

  BurnerWalletManager({required this.authToken});

  /// Derives the public key from a specific index
  Future<BurnerWallet?> createBurnerWallet({
    required int index,
    String? note,
  }) async {
    try {
      final derivationPath = Bip44DerivationPath.toUri([
        BipLevel(index: index, hardened: true),
      ]);

      final resolvedPath = await SeedVault.instance.resolveDerivationPath(
        derivationPath: derivationPath,
        purpose: Purpose.signSolanaTransaction,
      );

      final accounts = await SeedVault.instance.getParsedAccounts(
        authToken,
        filter: AccountFilter.byDerivationPath(resolvedPath),
      );

      final publicKey = accounts.firstOrNull?.publicKeyEncoded;
      if (publicKey == null) return null;

      final wallet = BurnerWallet(
        index: index,
        publicKey: publicKey,
        note: note,
      );
      _wallets.add(wallet);
      return wallet;
    } catch (_) {
      return null;
    }
  }

  /// Returns all created burner wallets
  List<BurnerWallet> getAllBurners() => _wallets;

  /// Gets the next available index (naive logic)
  int getNextIndex() {
    if (_wallets.isEmpty) return 0;
    final usedIndices = _wallets.map((w) => w.index).toSet();
    int next = 0;
    while (usedIndices.contains(next)) {
      next++;
    }
    return next;
  }

  /// Marks a burner wallet as used (helpful for hiding or tagging in UI)
  void markUsed(int index) {
    final wallet = _wallets.firstWhereOrNull((w) => w.index == index);
    if (wallet != null) {
      _wallets.remove(wallet);
      _wallets.add(
        BurnerWallet(
          index: wallet.index,
          publicKey: wallet.publicKey,
          note: wallet.note,
          used: true,
        ),
      );
    }
  }
}
