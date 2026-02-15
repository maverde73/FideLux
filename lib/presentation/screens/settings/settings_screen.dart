import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import 'package:fidelux/theme/fidelux_colors.dart';
import 'package:fidelux/theme/fidelux_spacing.dart';
import 'package:fidelux/theme/fidelux_radius.dart';

import '../../../app.dart';
import '../../../domain/entities/email_auth_state.dart';
import '../../providers/core_providers.dart';
import '../../providers/inbox_providers.dart';
import '../../providers/accounting_providers.dart';

/// Settings screen with card-based progressive disclosure.
///
/// Sections: Account · Preferences · About.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FideLuxSpacing.s4,
          vertical: FideLuxSpacing.s3,
        ),
        children: [
          // ── Account Section ──────────────────────────────────────────
          _SectionHeader(label: l10n.settingsSectionAccount),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FideLuxRadius.md),
              side: BorderSide(color: FideLuxColors.outlineVariant),
            ),
            child: Column(
              children: [
                Builder(builder: (context) {
                  final authAsync = ref.watch(emailAuthStateProvider);
                  final subtitle = authAsync.whenOrNull(
                    data: (state) => state.status == EmailAuthStatus.connected
                        ? l10n.emailConnected(state.email ?? '')
                        : l10n.emailNotConnected,
                  ) ?? l10n.emailNotConnected;
                  return ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(l10n.emailConfigTitle),
                    subtitle: Text(subtitle),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () =>
                        GoRouter.of(context).go('/settings/email-config'),
                  );
                }),
                const Divider(height: 1, indent: FideLuxSpacing.s12),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: Text(l10n.accountsTitle),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => GoRouter.of(context).go('/settings/accounts'),
                ),
                const Divider(height: 1, indent: FideLuxSpacing.s12),
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text('Pairing (Beta)'),
                  subtitle: const Text('Scan QR code to pair'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => GoRouter.of(context).go('/settings/pairing'),
                ),
              ],
            ),
          ),
          const SizedBox(height: FideLuxSpacing.s4),

          // ── Preferences Section ──────────────────────────────────────
          _SectionHeader(label: l10n.settingsSectionPreferences),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FideLuxRadius.md),
              side: BorderSide(color: FideLuxColors.outlineVariant),
            ),
            child: ListTile(
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
          ),
          const SizedBox(height: FideLuxSpacing.s4),

          // ── About Section ────────────────────────────────────────────
          _SectionHeader(label: l10n.settingsSectionAbout),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FideLuxRadius.md),
              side: BorderSide(color: FideLuxColors.outlineVariant),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.appTitle),
                  subtitle: const Text('v1.0.0'),
                ),
              ],
            ),
          ),
          const SizedBox(height: FideLuxSpacing.s6),

          // ── Logout / Reset ───────────────────────────────────────────
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FideLuxRadius.md),
              side: BorderSide(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.logoutTitle,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: Text(l10n.logoutSubtitle),
              onTap: () => _startLogout(context, ref, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startLogout(BuildContext context, WidgetRef ref, L l10n) async {
    // First confirmation
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(ctx).colorScheme.error,
          size: 40,
        ),
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.logoutConfirmButton),
          ),
        ],
      ),
    );

    if (firstConfirm != true || !context.mounted) return;

    // Second confirmation
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_forever,
          color: Theme.of(ctx).colorScheme.error,
          size: 40,
        ),
        title: Text(l10n.logoutFinalTitle),
        content: Text(l10n.logoutFinalBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.logoutFinalButton),
          ),
        ],
      ),
    );

    if (secondConfirm != true || !context.mounted) return;

    // Execute full data reset
    await _performLogout(ref);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.logoutSuccess)),
    );

    // Navigate to email config screen to re-setup
    GoRouter.of(context).go('/settings/email-config');
  }

  Future<void> _performLogout(WidgetRef ref) async {
    // 1. Clear email config + credentials
    await ref.read(emailRepositoryProvider).clearConfig();

    // 2. Clear crypto keys (secure storage)
    await ref.read(keyStorageRepositoryProvider).deleteAll();

    // 3. Delete all database tables
    final db = ref.read(databaseProvider);
    for (final table in db.allTables) {
      await db.delete(table).go();
    }

    // 4. Invalidate all providers to reset in-memory state
    ref.invalidate(emailAuthStateProvider);
    ref.invalidate(emailConfigProvider);
    ref.invalidate(inboxMessagesProvider);
    ref.invalidate(accountsProvider);
  }
}

/// Small section header label above each card group.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: FideLuxSpacing.s1,
        bottom: FideLuxSpacing.s2,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
