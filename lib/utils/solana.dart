// lib/solana/pubkey_helper.dart
import 'package:solana/solana.dart';

/// Converts a base58 string address into an Ed25519HDPublicKey.
/// Throws [FormatException] if the address is invalid.
Ed25519HDPublicKey toPublicKey(String address) {
  return Ed25519HDPublicKey.fromBase58(address);
}
