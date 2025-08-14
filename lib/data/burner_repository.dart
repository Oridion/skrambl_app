import 'package:skrambl_app/services/burner_wallet_management.dart';

class BurnerRepository {
  final BurnerWalletManager manager;

  BurnerRepository({required this.manager});

  Future<List<BurnerWallet>> fetchBurners() async {
    // If you later persist to Drift, read from DB here instead of manager memory.
    return manager.getAllBurners();
  }

  Future<BurnerWallet> createBurner(String label) async {
    final next = manager.getNextIndex();
    final created = await manager.createBurnerWallet(index: next, note: label);
    if (created == null) {
      throw Exception('Failed to create burner wallet via Seed Vault.');
    }
    return created;
  }
}
