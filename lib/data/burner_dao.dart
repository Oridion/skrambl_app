// lib/data/burner_dao.dart
import 'package:drift/drift.dart';
import 'package:skrambl_app/data/burner_entity.dart';
import 'local_database.dart'; // Your Database class that includes Burners table

part 'burner_dao.g.dart';

@DriftAccessor(tables: [Burners])
class BurnerDao extends DatabaseAccessor<LocalDatabase> with _$BurnerDaoMixin {
  BurnerDao(super.db);

  // ---------- Create / Upsert ----------

  Future<void> upsertBurner({required String pubkey, required int derivationIndex, String? note}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Use insertOnConflictUpdate so calling twice is idempotent
    await into(burners).insertOnConflictUpdate(
      BurnersCompanion.insert(
        pubkey: pubkey,
        derivationIndex: derivationIndex,
        note: Value(note),
        createdAt: Value(now),
      ),
    );
  }

  // ---------- Reads ----------

  // Show active first, newest used first
  Stream<List<Burner>> watchAllActive() {
    return (select(burners)
          ..where((b) => b.archived.equals(false))
          ..orderBy([
            // used first, then most recent use, then created
            (b) => OrderingTerm(expression: b.used, mode: OrderingMode.desc),
            (b) => OrderingTerm(expression: b.lastUsedAt, mode: OrderingMode.desc),
            (b) => OrderingTerm(expression: b.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  // Watch a single burner wallet
  Stream<Burner?> watchByPubkey(String pubkey) {
    return (select(burners)..where((b) => b.pubkey.equals(pubkey))).watchSingleOrNull();
  }

  // Is pubkey in the burner db
  Future<bool> isInLocalDb(String pubkey) async {
    final row = await (select(burners)..where((b) => b.pubkey.equals(pubkey))).getSingleOrNull();
    return row != null;
  }

  // Find burners in a set of address strings
  Future<Set<String>> findBurnersIn(Set<String> addrs) async {
    if (addrs.isEmpty) return {};
    final rows = await (select(burners)..where((b) => b.pubkey.isIn(addrs.toList()))).get();
    return rows.map((r) => r.pubkey).toSet();
  }

  // Get burner by pubkey
  Future<Burner?> getByPubkey(String pubkey) {
    return (select(burners)..where((b) => b.pubkey.equals(pubkey))).getSingleOrNull();
  }

  Future<List<Burner>> getAll() => select(burners).get();

  //Get next index.
  Future<int> nextBurnerIndex() async {
    // SELECT MAX(derivation_index) FROM burners;
    final q = await (selectOnly(burners)..addColumns([burners.derivationIndex.max()])).getSingle();

    final maxIdx = q.read(burners.derivationIndex.max());
    // start at 100 if table empty
    return (maxIdx ?? 99) + 1;
  }

  // ---------- Updates ----------

  Future<int> setNote(String pubkey, String? note) {
    return (update(
      burners,
    )..where((b) => b.pubkey.equals(pubkey))).write(BurnersCompanion(note: Value(note)));
  }

  Future<int> markUsed({required String pubkey, bool used = true}) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return customUpdate(
      'UPDATE burners SET used = ?, last_used_at = ?, tx_count = tx_count + 1 WHERE pubkey = ?',
      variables: [Variable.withBool(used), Variable.withInt(now), Variable.withString(pubkey)],
      updates: {burners},
    );
  }

  Future<int> bumpTxCountAndTouch({required String pubkey}) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return customUpdate(
      'UPDATE burners SET tx_count = tx_count + 1, used = 1, last_used_at = ? WHERE pubkey = ?',
      variables: [Variable<int>(now), Variable<String>(pubkey)],
      updates: {burners},
    );
  }

  Future<int> archive(String pubkey, {bool archived = true}) {
    return (update(
      burners,
    )..where((b) => b.pubkey.equals(pubkey))).write(BurnersCompanion(archived: Value(archived)));
  }

  // Optional: one-off cache touch (e.g., after a balance refresh)
  Future<int> touchSeen(String pubkey) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (update(
      burners,
    )..where((b) => b.pubkey.equals(pubkey))).write(BurnersCompanion(lastSeenAt: Value(now)));
  }
}
