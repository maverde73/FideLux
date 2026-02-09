import 'package:flutter_test/flutter_test.dart';
import 'package:fidelux/data/ai/receipt_categorizer.dart';
import 'package:fidelux/domain/entities/transaction_category.dart';

void main() {
  late ReceiptCategorizer categorizer;

  setUp(() {
    categorizer = ReceiptCategorizer();
  });

  test('categorizes Esselunga as groceries', () async {
    final result = await categorizer.categorize('Spesa Esselunga', null);
    expect(result.category, TransactionCategory.groceries);
    expect(result.confidence, greaterThan(0.5));
    expect(result.alert, isFalse);
  });

  test('categorizes prelievo bancomat as cash', () async {
    final result = await categorizer.categorize('prelievo bancomat', null);
    expect(result.category, TransactionCategory.cash);
    expect(result.alert, isFalse);
  });

  test('categorizes SNAI as gambling with alert flag', () async {
    final result = await categorizer.categorize('SNAI scommesse', null);
    expect(result.category, TransactionCategory.gambling);
    expect(result.alert, isTrue);
  });

  test('returns other for unknown merchant', () async {
    final result = await categorizer.categorize('Something completely unknown', null);
    expect(result.category, TransactionCategory.other);
    expect(result.confidence, 0.3);
  });

  test('case insensitive matching', () async {
    final result = await categorizer.categorize('ESSELUNGA MILANO', null);
    expect(result.category, TransactionCategory.groceries);
  });
}
