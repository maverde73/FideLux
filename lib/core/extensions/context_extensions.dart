import 'package:flutter/material.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

/// Extension methods on [BuildContext] for convenient access to theme
/// and localization.
extension ContextExtensions on BuildContext {
  /// Shorthand for `Theme.of(this)`.
  ThemeData get theme => Theme.of(this);

  /// Shorthand for `Theme.of(this).colorScheme`.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Shorthand for `Theme.of(this).textTheme`.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Shorthand for `L.of(this)!` — localized strings.
  L get l10n => L.of(this)!;
}
