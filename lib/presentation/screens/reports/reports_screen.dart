import 'package:flutter/material.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

/// Placeholder screen for the Reports tab.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabReports)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.placeholderScreenTitle(l10n.tabReports),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
