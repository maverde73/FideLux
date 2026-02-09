
import '../domain/entities/chain_event.dart';
import '../domain/repositories/chain_repository.dart';

/// Use case: Append a new event to the secure chain.
class AppendChainEvent {
  AppendChainEvent(this.chainRepository);

  final ChainRepository chainRepository;

  Future<ChainEvent> call(ChainEvent event) {
    return chainRepository.appendEvent(event);
  }
}
