import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import 'package:fidelux/presentation/providers/dashboard_providers.dart';

/// Main scaffold shell wrapping the 5-tab bottom navigation.
///
/// Uses Material 3 [NavigationBar] with icons and labels from
/// brand-guidelines.md §5.7.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  /// The navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final criticalAlertCount = ref.watch(criticalAlertCountProvider);

    return Scaffold(
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.mail_outline),
            selectedIcon: const Icon(Icons.mail),
            label: l10n.tabInbox,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: criticalAlertCount > 0,
              label: Text(criticalAlertCount.toString()),
              child: const Icon(Icons.dashboard_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: criticalAlertCount > 0,
              label: Text(criticalAlertCount.toString()),
              child: const Icon(Icons.dashboard),
            ),
            label: l10n.tabDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.tabLedger,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.tabReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
