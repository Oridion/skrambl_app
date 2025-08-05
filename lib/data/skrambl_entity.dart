import 'package:drift/drift.dart';

class Skrambls extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get note => text()();
  IntColumn get status => integer()(); // 0 = pending, 1 = complete, etc.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get destination => text()();
}
