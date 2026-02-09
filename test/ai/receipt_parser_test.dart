import 'package:flutter_test/flutter_test.dart';
import 'package:fidelux/data/ai/receipt_parser.dart';

void main() {
  late ReceiptParser parser;

  setUp(() {
    parser = ReceiptParser();
  });

  test('extracts total from standard Italian receipt', () async {
    const ocrText = '''
ESSELUNGA
Via Roma 15
Milano
P.IVA 01234567890
PANE INTEGRALE  2,50
LATTE FRESCO  1,80
MOZZARELLA  3,20
TOTALE EURO  47,32
CONTANTI  50,00
RESTO  2,68
''';

    final result = await parser.parse(ocrText);
    expect(result.total, 47.32);
    expect(result.confidence['total'], greaterThanOrEqualTo(0.9));
  });

  test('extracts date in dd/mm/yyyy format', () async {
    const ocrText = '''
COOP
12/01/2026
TOTALE  15,00
''';

    final result = await parser.parse(ocrText);
    expect(result.date, isNotNull);
    expect(result.date!.year, 2026);
    expect(result.date!.month, 1);
    expect(result.date!.day, 12);
  });

  test('extracts merchant from first lines', () async {
    const ocrText = '''
COOP LOMBARDIA
Viale Monza 23
Milano
P.IVA 01234567890
TOTALE  10,00
''';

    final result = await parser.parse(ocrText);
    expect(result.merchant, 'COOP LOMBARDIA');
  });

  test('extracts P.IVA', () async {
    const ocrText = '''
BAR SPORT
P.IVA 01234567890
TOTALE  5,00
''';

    final result = await parser.parse(ocrText);
    expect(result.vatNumber, '01234567890');
  });

  test('handles messy OCR with low confidence', () async {
    const ocrText = 'xXx TOTALE 47 32 xXx';

    final result = await parser.parse(ocrText);
    expect(result.total, 47.32);
    expect(result.confidence['total']!, lessThan(0.7));
  });

  test('returns null fields when nothing found', () async {
    const ocrText = 'xx';

    final result = await parser.parse(ocrText);
    expect(result.total, isNull);
    expect(result.merchant, isNull);
    expect(result.date, isNull);
  });

  test('parses receipt with multiple amounts and picks largest after TOTALE', () async {
    const ocrText = '''
PANIFICIO
PANE  2,50
LATTE  1,80
TOTALE  4,30
''';

    final result = await parser.parse(ocrText);
    expect(result.total, 4.30);
  });
}
