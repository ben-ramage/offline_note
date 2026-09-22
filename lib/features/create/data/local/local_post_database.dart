import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'local_post_database.g.dart';

class LocalPosts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();

  TextColumn get title => text()();
  TextColumn get paragraph => text()();

  TextColumn get imageUrl => text().nullable()();
  TextColumn get imageStoragePath => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
  BlobColumn get localImageBytes => blob().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  BoolColumn get isDraft => boolean().withDefault(const Constant(false))();
  DateTimeColumn get draftDate => dateTime().nullable()();

  TextColumn get syncState => text().nullable()();
  TextColumn get pendingAction => text().nullable()();
  TextColumn get lastSyncError => text().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalPosts])
class LocalPostDatabase extends _$LocalPostDatabase {
  LocalPostDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'offline_note_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
