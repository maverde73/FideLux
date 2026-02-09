import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai/mlkit_ocr_service.dart';
import '../../data/ai/rule_based_engine.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/repositories/ai_engine_repository.dart';
import '../../data/ai/receipt_parser.dart';
import 'accounting_providers.dart';

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return MlkitOcrService();
});

final aiEngineProvider = Provider<AiEngineRepository>((ref) {
  return RuleBasedEngine();
});

/// Parses a receipt image attached to an inbox message.
///
/// Returns null if the message has no attachments or OCR fails.
final receiptParseProvider = FutureProvider.family<ParsedReceipt?, String>((ref, messageId) async {
  final dao = ref.read(inboxDaoProvider);
  final message = await dao.getMessageById(messageId);
  if (message == null) return null;

  // The Drift InboxMessage doesn't carry attachment bytes — the domain
  // InboxMessage does. For now, OCR is triggered from the screen with
  // the domain object already in memory. This provider is a placeholder
  // for when we add attachment persistence to the DB.
  return null;
});
