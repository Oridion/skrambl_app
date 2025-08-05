// Drift setup
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'skrambl_entity.dart';

part 'local_database.g.dart';

@DriftDatabase(tables: [Skrambls])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'skrambl.sqlite'));
    if (file.existsSync()) {
      await file.delete(); // 🧹 Clean slate
    }
    return NativeDatabase(file);
  });
}
