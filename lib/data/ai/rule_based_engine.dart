import '../../domain/repositories/ai_engine_repository.dart';
import 'receipt_parser.dart';
import 'receipt_categorizer.dart';

/// MVP AI engine that uses deterministic rules for receipt parsing
/// and keyword-based categorization. Always available, runs offline.
class RuleBasedEngine implements AiEngineRepository {
  final ReceiptCategorizer _categorizer = ReceiptCategorizer();

  @override
  String get engineName => 'rule_based';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ParsedReceipt> parseReceipt(String ocrText, {String locale = 'it'}) {
    return ReceiptParser(locale: locale).parse(ocrText);
  }

  @override
  Future<CategorizeResult> categorize(String description, String? merchant) {
    return _categorizer.categorize(description, merchant);
  }
}
