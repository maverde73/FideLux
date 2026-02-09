/// Deterministic receipt parser for Italian receipts.
///
/// Extracts total, date, merchant, VAT number, fiscal code, and line items
/// from raw OCR text using regex patterns. No ML involved.
class ReceiptParser {
  final String locale;

  ReceiptParser({this.locale = 'it'});

  /// Parses raw OCR text into a structured [ParsedReceipt].
  Future<ParsedReceipt> parse(String ocrText) async {
    final lines = ocrText.split('\n').map((l) => l.trim()).toList();

    final totalResult = _extractTotal(lines);
    final dateResult = _extractDate(lines);
    final merchant = _extractMerchant(lines);
    final vatNumber = _extractVatNumber(ocrText);
    final fiscalCode = _extractFiscalCode(ocrText);
    final items = _extractItems(lines);

    final confidence = <String, double>{
      'total': totalResult.$2,
      'date': dateResult.$2,
      'merchant': merchant.$2,
      'vatNumber': vatNumber != null ? 0.9 : 0.0,
      'fiscalCode': fiscalCode != null ? 0.9 : 0.0,
    };

    return ParsedReceipt(
      merchant: merchant.$1,
      total: totalResult.$1,
      date: dateResult.$1,
      vatNumber: vatNumber,
      fiscalCode: fiscalCode,
      items: items,
      confidence: confidence,
      rawText: ocrText,
    );
  }

  // ── Total extraction ──────────────────────────────────────────────────

  static final _totalKeywordPattern = RegExp(
    r'(?:TOTALE\s*(?:EURO|EUR|COMPLESSIVO)?|TOT\.|IMPORTO)\s*[:\s€EUR]*\s*'
    r'(\d+[.,]\d{2})',
    caseSensitive: false,
  );

  static final _totalLoosePattern = RegExp(
    r'(?:TOTALE|TOT\.|IMPORTO)\s+(\d+)\s+(\d{2})',
    caseSensitive: false,
  );

  (double?, double) _extractTotal(List<String> lines) {
    final fullText = lines.join('\n');

    // Try exact keyword match first (high confidence).
    final exactMatch = _totalKeywordPattern.firstMatch(fullText);
    if (exactMatch != null) {
      final value = _parseNumber(exactMatch.group(1)!);
      if (value != null) return (value, 0.9);
    }

    // Try loose pattern for messy OCR: "TOTALE 47 32" → 47.32
    final looseMatch = _totalLoosePattern.firstMatch(fullText);
    if (looseMatch != null) {
      final integer = looseMatch.group(1)!;
      final decimal = looseMatch.group(2)!;
      final value = double.tryParse('$integer.$decimal');
      if (value != null) return (value, 0.6);
    }

    return (null, 0.0);
  }

  // ── Date extraction ───────────────────────────────────────────────────

  static final _datePattern = RegExp(
    r'(\d{2})[/\-.](\d{2})[/\-.](\d{2,4})',
  );

  (DateTime?, double) _extractDate(List<String> lines) {
    for (final line in lines) {
      final match = _datePattern.firstMatch(line);
      if (match != null) {
        final day = int.tryParse(match.group(1)!);
        final month = int.tryParse(match.group(2)!);
        var year = int.tryParse(match.group(3)!);
        if (day == null || month == null || year == null) continue;
        if (year < 100) year += 2000;
        if (month < 1 || month > 12 || day < 1 || day > 31) continue;
        try {
          final date = DateTime(year, month, day);
          return (date, 0.9);
        } catch (_) {
          continue;
        }
      }
    }
    return (null, 0.0);
  }

  // ── Merchant extraction ───────────────────────────────────────────────

  static final _skipLinePattern = RegExp(
    r'^(\d+$|P\.?\s*IVA|C\.?\s*F\.?|PARTITA\s*IVA|COD\.?\s*FISC)',
    caseSensitive: false,
  );

  (String?, double) _extractMerchant(List<String> lines) {
    for (final line in lines) {
      if (line.length < 3) continue;
      if (_skipLinePattern.hasMatch(line)) continue;
      // Skip lines that are just numbers or dates.
      if (RegExp(r'^\d[\d/.\-\s]*$').hasMatch(line)) continue;
      return (line, 0.7);
    }
    return (null, 0.0);
  }

  // ── VAT number ────────────────────────────────────────────────────────

  static final _vatPattern = RegExp(
    r'(?:P\.?\s*IVA|P\.?\s*I\.|PARTITA\s*IVA)\s*:?\s*(\d{11})',
    caseSensitive: false,
  );

  String? _extractVatNumber(String text) {
    final match = _vatPattern.firstMatch(text);
    return match?.group(1);
  }

  // ── Fiscal code ───────────────────────────────────────────────────────

  static final _fiscalCodePattern = RegExp(
    r'(?:C\.?\s*F\.?|COD\.?\s*FISC\.?)\s*:?\s*([A-Z0-9]{16})',
    caseSensitive: false,
  );

  String? _extractFiscalCode(String text) {
    final match = _fiscalCodePattern.firstMatch(text);
    return match?.group(1)?.toUpperCase();
  }

  // ── Line items ────────────────────────────────────────────────────────

  static final _itemPattern = RegExp(
    r'^(.+?)\s+(\d+[.,]\d{2})\s*$',
  );

  static final _quantityItemPattern = RegExp(
    r'^(.+?)\s+(\d+)\s*[xX]\s*(\d+[.,]\d{2})',
  );

  List<ReceiptItem> _extractItems(List<String> lines) {
    final items = <ReceiptItem>[];
    for (final line in lines) {
      // Skip total/keyword lines.
      if (RegExp(r'TOTALE|TOT\.|IMPORTO', caseSensitive: false).hasMatch(line)) continue;

      final qtyMatch = _quantityItemPattern.firstMatch(line);
      if (qtyMatch != null) {
        items.add(ReceiptItem(
          description: qtyMatch.group(1)!.trim(),
          price: _parseNumber(qtyMatch.group(3)!),
          quantity: int.tryParse(qtyMatch.group(2)!),
        ));
        continue;
      }

      final itemMatch = _itemPattern.firstMatch(line);
      if (itemMatch != null) {
        final desc = itemMatch.group(1)!.trim();
        // Skip very short descriptions that are likely noise.
        if (desc.length < 2) continue;
        items.add(ReceiptItem(
          description: desc,
          price: _parseNumber(itemMatch.group(2)!),
          quantity: 1,
        ));
      }
    }
    return items;
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  static double? _parseNumber(String raw) {
    final normalized = raw.replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}

/// Structured data extracted from a receipt.
class ParsedReceipt {
  final String? merchant;
  final double? total;
  final DateTime? date;
  final String? vatNumber;
  final String? fiscalCode;
  final List<ReceiptItem> items;
  final Map<String, double> confidence;
  final String rawText;

  const ParsedReceipt({
    this.merchant,
    this.total,
    this.date,
    this.vatNumber,
    this.fiscalCode,
    this.items = const [],
    this.confidence = const {},
    this.rawText = '',
  });
}

/// A single line item on a receipt.
class ReceiptItem {
  final String description;
  final double? price;
  final int? quantity;

  const ReceiptItem({
    required this.description,
    this.price,
    this.quantity,
  });
}
