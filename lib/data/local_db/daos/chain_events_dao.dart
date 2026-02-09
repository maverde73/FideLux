
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'chain_events_dao.g.dart';

@DriftAccessor(tables: [ChainEvents])
class ChainEventsDao extends DatabaseAccessor<AppDatabase> with _$ChainEventsDaoMixin {
  ChainEventsDao(AppDatabase db) : super(db);

  Future<int> insertEvent(ChainEventsCompanion event) => into(chainEvents).insert(event);

  Future<ChainEvent?> getEventBySequence(int sequence) => (select(chainEvents)..where((t) => t.sequence.equals(sequence))).getSingleOrNull();

  Future<ChainEvent?> getLastEvent() {
    return (select(chainEvents)
      ..orderBy([(t) => OrderingTerm(expression: t.sequence, mode: OrderingMode.desc)])
      ..limit(1))
    .getSingleOrNull();
  }

  Future<List<ChainEvent>> getAllEvents({int? limit, int? offset}) {
    return (select(chainEvents)
      ..orderBy([(t) => OrderingTerm(expression: t.sequence, mode: OrderingMode.asc)])
      ..limit(limit ?? -1, offset: offset))
    .get();
  }
  
  Stream<List<ChainEvent>> watchRecentEvents({int limit = 50}) {
    return (select(chainEvents)
      ..orderBy([(t) => OrderingTerm(expression: t.sequence, mode: OrderingMode.desc)])
      ..limit(limit))
    .watch();
  }
  
  Future<int> getEventCount() async {
    final count = chainEvents.sequence.count();
    final query = selectOnly(chainEvents)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
