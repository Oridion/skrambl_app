// lib/data/tables/burners.dart
import 'package:drift/drift.dart';

class Burners extends Table {
  // Wallet address generated from Seed Vault (unique)
  TextColumn get pubkey => text()();
  // Derivation index used to create this burner (helps re-derive later)
  IntColumn get derivationIndex => integer()();

  // Optional user note/label
  TextColumn get note => text().nullable()();

  // Flags & counters
  BoolColumn get used => boolean().withDefault(const Constant(false))();
  IntColumn get txCount => integer().withDefault(const Constant(0))();

  // Timestamps (unix seconds)
  IntColumn get createdAt => integer().withDefault(const Constant(0))(); // set in DAO
  IntColumn get lastUsedAt => integer().nullable()(); // null if never used
  IntColumn get lastSeenAt => integer().nullable()(); // (optional) cache of when we last refreshed

  // Lifecycle
  BoolColumn get archived => boolean().withDefault(const Constant(false))(); // soft-delete

  @override
  Set<Column> get primaryKey => {pubkey};

  @override
  List<String> get customConstraints => [
    // speed up joins with pods.creator and lookups by index
    'UNIQUE(derivation_index)',
  ];
}
