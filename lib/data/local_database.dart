// Drift setup
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'skrambl_entity.dart'; // will contain Pods and optional Skrambls

part 'local_database.g.dart';

@DriftDatabase(tables: [Pods /*, Skrambls if you still need it */])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase({bool resetOnStart = false})
    : super(_openConnection(resetOnStart));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Add future migrations here
    },
    beforeOpen: (details) async {
      // pragmas, foreign_keys, etc. if needed
    },
  );
}

LazyDatabase _openConnection(bool resetOnStart) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'skrambl.sqlite'));

    if (resetOnStart && file.existsSync()) {
      await file.delete(); // ⚠️ Only when you pass resetOnStart: true
    }
    return NativeDatabase.createInBackground(file);
  });
}
