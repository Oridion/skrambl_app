// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:solana/solana.dart';
// import 'package:solana_seed_vault/solana_seed_vault.dart';

// class SolanaSigningService {
//   static Future<String> signAndSend({
//     required String base64Tx,
//     required AuthToken authToken,
//     required String walletAddress,
//   }) async {
//     final txBytes = base64Decode(base64Tx);
//     final transaction = Message.fromBytes(
//       txBytes,
//     ); // ⚠️ This is Message, not Transaction

//     final signature = await SeedVault.signTransaction(
//       authToken: authToken,
//       derivationPath: DerivationPath.bip44Change(account: 0, change: 0),
//       message: transaction,
//     );

//     final rpc = RpcClient('https://api.mainnet-beta.solana.com');
//     final sig = await rpc.sendTransaction(
//       signature,
//       skipPreflight: true,
//       preflightCommitment: Commitment.confirmed,
//     );

//     return sig;
//   }
// }
