import 'package:intl/intl.dart';

/// Formats monetary amounts according to locale conventions.
///
/// Italian: `€1.234,56` — English: `€1,234.56`
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [amount] for the given [locale].
  ///
  /// Uses the EUR symbol by default.
  static String format(double amount, {String locale = 'it'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '€',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formats [amount] without decimals (for dashboard KPIs).
  static String formatCompact(double amount, {String locale = 'it'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '€',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
