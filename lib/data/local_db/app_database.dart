
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import '../../domain/entities/transaction_category.dart';

part 'app_database.g.dart'; // generated file

// --- Tables ---

class Accounts extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get type => text()(); // enum string
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  IntColumn get initialBalance => integer()(); // cents
  IntColumn get currentBalance => integer()(); // cents
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChainEvents extends Table {
  IntColumn get sequence => integer()();

  @override
  Set<Column> get primaryKey => {sequence};
  TextColumn get previousHash => text().withLength(min: 64, max: 64)();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get eventType => text()();
  TextColumn get payload => text()(); // JSON
  TextColumn get sharerSignature => text().nullable()();
  TextColumn get keeperSignature => text()();
  TextColumn get metadataSource => text()();
  IntColumn get metadataTrustLevel => integer()();
  TextColumn get metadataAiEngine => text().nullable()();
  TextColumn get hash => text().withLength(min: 64, max: 64)();
}

class Transactions extends Table {
  TextColumn get id => text()(); // UUID
  IntColumn get chainEventSequence => integer().references(ChainEvents, #sequence)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get amount => integer()(); // cents (negative for expense)
  TextColumn get description => text()();
  TextColumn get merchant => text().nullable()();
  TextColumn get category => text().map(const TransactionCategoryConverter())();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get receiptImagePath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class InboxMessages extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get emailMessageId => text().unique()();
  DateTimeColumn get receivedAt => dateTime()();
  TextColumn get senderEmail => text()();
  TextColumn get subject => text().nullable()();
  TextColumn get bodyText => text().nullable()();
  TextColumn get sharerSignature => text().nullable()();
  BoolColumn get signatureValid => boolean().nullable()();
  TextColumn get status => text()(); // enum string
  DateTimeColumn get processedAt => dateTime().nullable()();
  IntColumn get linkedChainEventSequence => integer().nullable().references(ChainEvents, #sequence)();

  @override
  Set<Column> get primaryKey => {id};
}

// --- Type Converters ---

class TransactionCategoryConverter extends TypeConverter<TransactionCategory, String> {
  const TransactionCategoryConverter();
  
  @override
  TransactionCategory fromSql(String fromDb) {
    return TransactionCategory.values.firstWhere(
      (e) => e.name == fromDb, 
      orElse: () => TransactionCategory.other,
    );
  }

  @override
  String toSql(TransactionCategory value) {
    return value.name;
  }
}

// --- Database Accessor (Database Class) ---

@DriftDatabase(tables: [Accounts, ChainEvents, Transactions, InboxMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fidelux.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
