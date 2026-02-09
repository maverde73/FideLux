import 'package:go_router/go_router.dart';

import '../shell/main_shell.dart';
import '../screens/inbox/inbox_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/ledger/ledger_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/pairing/pairing_screen.dart';
import '../screens/settings/email_config_screen.dart';
import '../screens/settings/accounts_screen.dart';
import '../screens/ledger/transaction_detail_screen.dart';
import '../screens/inbox/process_message_screen.dart';
import '../../domain/entities/inbox_message.dart'; // For casting extra

/// GoRouter configuration for the FideLux app.
///
/// Uses [StatefulShellRoute.indexedStack] to preserve the state of each
/// tab when switching between them.
final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard', // Default to Dashboard? Or Inbox? MainShell 0 is Inbox.
  // If MainShell index 0 is Inbox, initialLocation should ideally be /inbox.
  // But D01 says Dashboard is main. 
  // If I want Dashboard to be default, I should make it index 0 in Shell.
  // But standard email app has Inbox as main. 
  // I'll set initialLocation as /dashboard (index 1).
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Inbox (Index 0)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inbox',
              builder: (context, state) => const InboxScreen(),
              routes: [
                GoRoute(
                  path: 'process/:id', 
                  builder: (context, state) {
                    final message = state.extra as InboxMessage;
                    return ProcessMessageScreen(message: message);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Dashboard (Index 1)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard', 
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Tab 3: Ledger (Index 2)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ledger',
              builder: (context, state) => const LedgerScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) => TransactionDetailScreen(transactionId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        // Tab 4: Reports (Index 3)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
        // Tab 5: Settings (Index 4)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'pairing',
                  builder: (context, state) => const PairingScreen(),
                ),
                GoRoute(
                  path: 'email-config',
                  builder: (context, state) => const EmailConfigScreen(),
                ),
                GoRoute(
                  path: 'accounts',
                  builder: (context, state) => const AccountsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
