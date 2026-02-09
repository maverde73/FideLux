// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class LIt extends L {
  LIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'FideLux';

  @override
  String get tabInbox => 'Inbox';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabLedger => 'Contabilità';

  @override
  String get tabReports => 'Report';

  @override
  String get tabSettings => 'Impostazioni';

  @override
  String get sharer => 'Affidante';

  @override
  String get keeper => 'Custode';

  @override
  String get fideluxScore => 'Punteggio FideLux';

  @override
  String get eventChain => 'Catena Eventi';

  @override
  String get sos => 'SOS';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageIt => 'Italiano';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String placeholderScreenTitle(String screenName) {
    return '$screenName - In arrivo';
  }

  @override
  String currencyFormat(String amount) {
    return '€$amount';
  }
}
