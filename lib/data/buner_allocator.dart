import 'dart:math';
import 'package:solana_seed_vault/solana_seed_vault.dart';

class BurnerAllocationException implements Exception {
  final String message;
  BurnerAllocationException(this.message);
  @override
  String toString() => 'BurnerAllocationException: $message';
}

class BurnerAllocator {
  static const int _minIndex = 0;
  static const int _maxIndexInclusive = 0x7FFFFFFF; // 2,147,483,647
  final Random _rng = Random.secure();

  Future<int> allocate({
    required AuthToken token,
    required Future<String> Function({required AuthToken authToken, required int index})
    exposeAndGetPubkeyAtIndex,
    required Future<bool> Function(String pubkey) isInLocalDb,
    required Future<bool> Function(String pubkey) hasOnChainHistory,
    int maxAttempts = 30,
    int? preferStartAbove, // e.g., 100
    Duration retryDelay = const Duration(milliseconds: 50),
  }) async {
    int attempts = 0;
    int rpcErrors = 0;

    while (attempts < maxAttempts) {
      attempts++;

      final idx = _randomIndex(preferStartAbove: preferStartAbove);
      final pub = await exposeAndGetPubkeyAtIndex(authToken: token, index: idx);

      if (await isInLocalDb(pub)) {
        if (retryDelay > Duration.zero) await Future.delayed(retryDelay);
        continue;
      }

      bool? history;
      try {
        history = await hasOnChainHistory(pub); // true=used, false=clean
      } catch (_) {
        rpcErrors++;
        if (retryDelay > Duration.zero) await Future.delayed(retryDelay);
        continue; // transient RPC issue → try another random index
      }

      if (history == true) {
        if (retryDelay > Duration.zero) await Future.delayed(retryDelay);
        continue;
      }
      return idx;
    }

    // Exhausted attempts → fail
    final msg = (rpcErrors == maxAttempts)
        ? 'Network error while checking address history. Please try again.'
        : 'Could not allocate a fresh burner right now. Please try again.';
    throw BurnerAllocationException(msg);
  }

  int _randomIndex({int? preferStartAbove}) {
    final floor = (preferStartAbove != null && preferStartAbove > _minIndex) ? preferStartAbove : _minIndex;
    final span = (_maxIndexInclusive - floor) + 1;
    return floor + _rng.nextInt(span);
  }
}
