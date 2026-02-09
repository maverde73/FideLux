import '../../domain/entities/transaction_category.dart';
import '../../domain/repositories/ai_engine_repository.dart';

/// Rule-based transaction categorizer using keyword matching.
///
/// Matches keywords against description + merchant (case-insensitive).
/// Sets `alert = true` for gambling-related categories.
class ReceiptCategorizer {
  static const _keywordMap = <TransactionCategory, List<String>>{
    TransactionCategory.groceries: [
      'esselunga', 'coop', 'conad', 'lidl', 'eurospin', 'supermercato',
      'carrefour', 'pam', 'despar', 'penny', 'aldi', 'md discount',
    ],
    TransactionCategory.dining: [
      'ristorante', 'pizzeria', 'bar', 'caffè', 'caffe', 'mcdonald',
      'burger king', 'trattoria', 'osteria', 'pub', 'kebab',
    ],
    TransactionCategory.transport: [
      'trenitalia', 'italo', 'atm milano', 'autostrada', 'benzina',
      'eni', 'q8', 'ip', 'shell', 'tamoil', 'taxi', 'uber', 'telepass',
    ],
    TransactionCategory.utilities: [
      'enel', 'eni gas', 'acea', 'tim', 'vodafone', 'fastweb', 'wind',
      'iliad', 'a2a', 'iren', 'hera', 'sorgenia',
    ],
    TransactionCategory.health: [
      'farmacia', 'parafarmacia', 'ospedale', 'medico', 'dentista',
      'ottico', 'sanitaria',
    ],
    TransactionCategory.entertainment: [
      'cinema', 'teatro', 'netflix', 'spotify', 'playstation', 'xbox',
      'steam', 'disney', 'concerto', 'museo',
    ],
    TransactionCategory.clothing: [
      'zara', 'h&m', 'ovs', 'decathlon', 'benetton', 'intimissimi',
      'calzedonia', 'primark', 'nike', 'adidas',
    ],
    TransactionCategory.cash: [
      'prelievo', 'bancomat', 'sportello',
    ],
    TransactionCategory.gambling: [
      'snai', 'sisal', 'lottomatica', 'bet365', 'pokerstars',
      'betfair', 'goldbet', 'eurobet', 'william hill', 'scommesse',
      'slot', 'gratta',
    ],
    TransactionCategory.education: [
      'università', 'universita', 'scuola', 'libreria', 'feltrinelli',
      'mondadori',
    ],
    TransactionCategory.subscriptions: [
      'abbonamento', 'subscription', 'prime', 'apple music',
    ],
    TransactionCategory.housing: [
      'affitto', 'mutuo', 'condominio', 'immobiliare',
    ],
  };

  /// Categorizes a transaction based on [description] and optional [merchant].
  Future<CategorizeResult> categorize(String description, String? merchant) async {
    final searchText = '${description.toLowerCase()} ${(merchant ?? '').toLowerCase()}';

    for (final entry in _keywordMap.entries) {
      for (final keyword in entry.value) {
        if (searchText.contains(keyword.toLowerCase())) {
          return CategorizeResult(
            category: entry.key,
            confidence: keyword.length > 4 ? 0.85 : 0.7,
            alert: entry.key == TransactionCategory.gambling,
          );
        }
      }
    }

    return const CategorizeResult(
      category: TransactionCategory.other,
      confidence: 0.3,
    );
  }
}
