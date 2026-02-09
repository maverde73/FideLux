
import 'package:drift/drift.dart';
import '../../domain/entities/inbox_message.dart';
import '../../domain/repositories/email_repository.dart';
import '../../data/local_db/daos/inbox_dao.dart';
import '../../data/local_db/app_database.dart'; // Companion

class FetchInbox {
  final EmailRepository _repository;
  final InboxDao _inboxDao;

  FetchInbox(this._repository, this._inboxDao);

  // Executes the fetch operation.
  // Returns a list of newly fetched messages.
  Future<List<InboxMessage>> call() async {
    if (!await _repository.isConfigured()) {
       return [];
    }

    try {
      final messages = await _repository.fetchNewMessages();
      
      for (var msg in messages) {
        // Insert into DB. Unique constraint on emailMessageId prevents duplicates.
        // We use insertOrIgnore mode in DAO usually or handle exception.
        // DAO `insertMessage` uses insertOrIgnore mode.
        
        await _inboxDao.insertMessage(
          InboxMessagesCompanion(
            id: Value(msg.id),
            emailMessageId: Value(msg.emailMessageId),
            receivedAt: Value(msg.receivedAt),
            senderEmail: Value(msg.senderEmail),
            subject: Value(msg.subject),
            bodyText: Value(msg.bodyText),
            sharerSignature: Value(msg.sharerSignature),
            signatureValid: Value(msg.signatureValid), // bool?
            status: Value(msg.status.name),
            // processedAt is null
            // linkedChainEvent is null
          ),
        );
      }
      
      return messages;
    } catch (e) {
      // Log error?
      rethrow;
    }
  }
}
