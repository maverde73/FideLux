import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

import '../../../app.dart';

/// Settings screen with a working language switch (IT/EN).
///
/// Uses the [localeProvider] from `app.dart` to update the app locale
/// in real time via Riverpod.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Language switch ──────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              underline: const SizedBox.shrink(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).state = newLocale;
                }
              },
              items: [
                DropdownMenuItem(
                  value: const Locale('it'),
                  child: Text(l10n.settingsLanguageIt),
                ),
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.settingsLanguageEn),
                ),
              ],
            ),
          ),
          const Divider(),

          // ── Pairing ──────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('Pairing (Beta)'),
            subtitle: const Text('Scan QR code to pair'),
            onTap: () => GoRouter.of(context).go('/settings/pairing'),
          ),
          const Divider(),

          // ── Email Config ─────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Email Configuration'),
            subtitle: const Text('Configure IMAP/SMTP'),
            onTap: () => GoRouter.of(context).go('/settings/email-config'),
          ),
          const Divider(),
          
          // ── Placeholder ─────────────────────────────────────────────
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.placeholderScreenTitle(l10n.tabSettings),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
