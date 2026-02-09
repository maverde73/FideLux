// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FideLux';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabLedger => 'Ledger';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabSettings => 'Settings';

  @override
  String get sharer => 'Sharer';

  @override
  String get keeper => 'Keeper';

  @override
  String get fideluxScore => 'FideLux Score';

  @override
  String get eventChain => 'Event Chain';

  @override
  String get sos => 'SOS';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageIt => 'Italiano';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String placeholderScreenTitle(String screenName) {
    return '$screenName - Coming Soon';
  }

  @override
  String currencyFormat(String amount) {
    return '€$amount';
  }
}
