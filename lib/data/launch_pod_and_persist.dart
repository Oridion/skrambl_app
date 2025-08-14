// import '../data/local/local_database.dart';
// import '../data/local/pod_dao.dart';
// import '../data/local/skrambl_entity.dart'; // PodStatus
// import '../models/launch_args.dart';        // define below
// import '../providers/seed_vault_provider.dart';
// import '../rpc/helius_send.dart';           // your sendSignedTx()

// class LaunchService {
//   final LocalDatabase db;
//   final PodDao dao;
//   final SeedVaultProvider seedVault;

//   LaunchService(this.db, this.dao, this.seedVault);

//   /// Returns local pod row id
//   Future<String> launchAndPersist(LaunchArgs args) async {
//     // 1) Insert row as "launching"
//     final localId = await dao.createDraft(
//       creator: args.creator,
//       podId: args.podId,
//       lamports: args.lamports,
//       mode: args.mode,
//       delaySeconds: args.delaySeconds,
//       showMemo: args.showMemo,
//       note: args.note,
//       passcodePlain: args.passcodePlain,   // optional
//       passcodeHash32: args.passcodeHash32, // preferred
//     );

//     try {
//       // 2) Ask Lambda for unsigned message + (optional) pod PDA
//       final unsigned = await args.fetchUnsignedMessage(); // returns {messageB64, podPda?}

//       await dao.attachUnsignedMessage(
//         id: localId,
//         podPda: unsigned.podPda,
//         unsignedMessageB64: unsigned.messageB64,
//       );

//       // 3) Sign with Seed Vault
//       final signedTxB64 = await seedVault.signMessageBase64(unsigned.messageB64);

//       // 4) Submit to RPC
//       final sig = await sendSignedTx(signedTxB64);

//       // 5) Persist submission
//       await dao.markSubmitted(id: localId, signature: sig);

//       // (optional) kick off your watcher elsewhere
//       return localId;
//     } catch (e) {
//       await dao.markFailed(id: localId, message: e.toString());
//       rethrow;
//     }
//   }
// }
