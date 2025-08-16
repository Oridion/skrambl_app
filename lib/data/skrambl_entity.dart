import 'package:drift/drift.dart';

@DataClassName('Pod')
class Pods extends Table {
  // Local primary key (stable for UI; not the on-chain PDA)
  TextColumn get id => text()(); // uuid or "<creator>-<podId>-<ts>"

  // On-chain identifiers
  TextColumn get podPda => text().nullable()(); // base58 PDA once known
  TextColumn get creator => text()(); // parent wallet base58
  IntColumn get podId => integer().nullable()(); // your u16 id used in seeds

  // User args at launch
  IntColumn get lamports => integer()();
  IntColumn get mode => integer()(); // 0=instant, 1=delay...
  IntColumn get delaySeconds => integer().withDefault(const Constant(0))();
  BoolColumn get showMemo => boolean().withDefault(const Constant(false))();

  // escape handling (nullable so we can erase)
  TextColumn get escapeCode => text().nullable()();

  // Status (enum int)
  IntColumn get status => integer()(); // see PodStatus below
  TextColumn get statusMsg => text().nullable()();

  // Chain fields
  TextColumn get location => text().nullable()();
  TextColumn get destination => text()();

  // Signatures
  TextColumn get launchSig => text().nullable()();
  TextColumn get lastSig => text().nullable()();

  // Timestamps (unix seconds)
  IntColumn get draftedAt => integer()(); // local row creation
  IntColumn get submittedAt => integer().nullable()();
  IntColumn get finalizedAt => integer().nullable()();

  // Debug / resume
  TextColumn get unsignedMessageB64 => text().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

enum PodStatus {
  drafting, // 0: created locally, no unsigned tx yet
  launching, // 1: unsigned tx fetched, ready to sign/send
  submitted, // 2: sent to chain, awaiting scramble process
  scrambling, // 3: in Oridion hops
  delivering, // 4: withdrawal in progress
  finalized, // 5: delivered and finalized
  failed, // 6: critical mid-flight failure
}

extension PodStatusX on PodStatus {
  int get code => index;
  static PodStatus fromCode(int c) => PodStatus.values[c];
}
