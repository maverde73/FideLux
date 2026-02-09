import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';

import 'theme/fidelux_theme.dart';
import 'presentation/router/app_router.dart';

/// Riverpod provider for the current locale.
///
/// Used by [SettingsScreen] to switch language in real time.
final localeProvider = StateProvider<Locale>((ref) => const Locale('it'));

/// Root widget for the FideLux application.
///
/// A [ConsumerWidget] that reads the locale from [localeProvider] and
/// configures [MaterialApp.router] with the FideLux theme, localization
/// delegates, and GoRouter.
class FideLuxApp extends ConsumerWidget {
  const FideLuxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'FideLux',
      debugShowCheckedModeBanner: false,
      theme: fideluxTheme,
      locale: locale,
      supportedLocales: L.supportedLocales,
      localizationsDelegates: const [
        L.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
