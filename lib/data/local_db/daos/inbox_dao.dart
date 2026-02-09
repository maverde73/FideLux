
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'inbox_dao.g.dart';

@DriftAccessor(tables: [InboxMessages])
class InboxDao extends DatabaseAccessor<AppDatabase> with _$InboxDaoMixin {
  InboxDao(AppDatabase db) : super(db);

  Future<void> insertMessage(InboxMessagesCompanion message) => into(inboxMessages).insert(message, mode: InsertMode.insertOrIgnore);

  Future<List<InboxMessage>> getPendingMessages() {
    return (select(inboxMessages)
      ..where((t) => t.status.equals('verified') & t.processedAt.isNull()))
    .get();
  }
  
  Stream<List<InboxMessage>> watchPendingMessages() {
    return (select(inboxMessages)
      ..where((t) => t.status.equals('verified') & t.processedAt.isNull()))
    .watch();
  }
  
  Future<void> markAsProcessed(String id, int chainSequence) {
    return (update(inboxMessages)..where((t) => t.id.equals(id))).write(
      InboxMessagesCompanion(
        status: const Value('processed'),
        processedAt: Value(DateTime.now()),
        linkedChainEventSequence: Value(chainSequence),
      ),
    );
  }
}
