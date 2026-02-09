import '../../data/ai/receipt_parser.dart';
import '../entities/transaction_category.dart';

/// Contract for AI-powered receipt parsing and categorization.
///
/// MVP uses a deterministic rule-based engine. The interface allows
/// swapping in an LLM-based engine in the future without touching
/// the presentation layer.
abstract class AiEngineRepository {
  /// Parses OCR text into structured receipt data.
  Future<ParsedReceipt> parseReceipt(String ocrText, {String locale = 'it'});

  /// Categorizes a transaction based on description and merchant.
  Future<CategorizeResult> categorize(String description, String? merchant);

  /// Whether this engine is currently available.
  Future<bool> isAvailable();

  /// Engine identifier for event metadata.
  String get engineName;
}

/// Result of automatic categorization.
class CategorizeResult {
  final TransactionCategory category;
  final double confidence;
  final bool alert;

  const CategorizeResult({
    required this.category,
    required this.confidence,
    this.alert = false,
  });
}
