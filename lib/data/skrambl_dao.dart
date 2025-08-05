// dao/skrambl_dao.dart

import '../models/skrambl_model.dart';
import './local_database.dart';

// ✅ this line fixed to use the generated class
extension SkramblMapper on Skrambl {
  SkramblModel toModel() {
    return SkramblModel(
      id: id,
      note: note,
      status: status,
      createdAt: createdAt,
      destination: destination,
    );
  }
}

class SkramblDao {
  final LocalDatabase db;

  SkramblDao(this.db);

  Future<List<SkramblModel>> getAllSkrambls() async {
    final result = await db.select(db.skrambls).get();
    return result.map((row) => row.toModel()).toList();
  }

  Stream<List<SkramblModel>> watchSkrambls() {
    return db
        .select(db.skrambls)
        .watch()
        .map((rows) => rows.map((row) => row.toModel()).toList());
  }

  Future<void> insertSkrambl(SkramblsCompanion skrambl) {
    return db.into(db.skrambls).insertOnConflictUpdate(skrambl);
  }

  Future<void> deleteSkrambl(int id) {
    return (db.delete(db.skrambls)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<SkramblModel?> getSkramblById(int id) async {
    final result = await (db.select(
      db.skrambls,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return result?.toModel();
  }
}
