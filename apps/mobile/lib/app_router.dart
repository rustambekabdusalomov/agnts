import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart' show FeedbackStatusEnum;

import 'core/data.dart';
import 'core/flavor.dart';
import 'core/session.dart';
import 'features/admin/admin_admins_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_data.dart';
import 'features/admin/admin_feedback_screen.dart';
import 'features/admin/admin_more_screen.dart';
import 'features/admin/admin_users_screen.dart';
import 'features/admin/admin_workspaces_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/ci/ci_failure_screen.dart';
import 'features/ci/ci_screen.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_queue.dart';
import 'features/learn/learn_screen.dart';
import 'features/learn/lesson_screen.dart';
import 'features/more/more_screen.dart';
import 'features/repos/repo_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/tickets/ticket_screen.dart';
import 'features/tickets/tickets_screen.dart';
import 'l10n/app_localizations.dart';
import 'main.dart' show signOut;
import 'theme.dart';
import 'widgets/ui.dart';

/// Rebuilds the router's redirect when the session or the account changes.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
    ref.listen(adminProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionListenable(ref);
  final adminApp = ref.watch(adminAppProvider);
  final home = adminApp ? '/admin' : '/home';
  return GoRouter(
    initialLocation: home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final s = ref.read(sessionProvider);
      if (s.isLoading) return null;
      final signedIn = s.value != null;
      final at = state.matchedLocation;
      if (!signedIn) return at == '/login' ? null : '/login';
      // An account in the wrong app: the admin app is for system Admins, and
      // an Admin account with no workspaces has nothing in the user app.
      final admin = ref.read(adminProvider);
      final wrong = admin != null && (adminApp ? !admin.admin : admin.only);
      if (wrong) return at == '/wrong-app' ? null : '/wrong-app';
      if (at == '/login' || at == '/wrong-app') return home;
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/wrong-app', builder: (_, _) => const _WrongApp()),
      if (adminApp) ...[
        GoRoute(path: '/admin/admins', builder: (_, _) => const AdminAdminsScreen()),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => _AdminShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/workspaces', builder: (_, _) => const AdminWorkspacesScreen())]),
            StatefulShellBranch(
              routes: [GoRoute(path: '/admin/users', builder: (_, s) => AdminUsersScreen(filter: s.uri.queryParameters['f']))],
            ),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/feedback', builder: (_, _) => const AdminFeedbackScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/admin/more', builder: (_, _) => const AdminMoreScreen())]),
          ],
        ),
      ] else ...[
        // Notification taps deep-link here.
        GoRoute(path: '/tickets/:key', builder: (_, s) => TicketScreen(ticketKey: s.pathParameters['key']!)),
        GoRoute(
          path: '/repos/:id',
          builder: (_, s) => RepoScreen(id: int.parse(s.pathParameters['id']!), name: s.uri.queryParameters['name'] ?? ''),
        ),
        GoRoute(path: '/learn', builder: (_, s) => LearnScreen(ticketKey: s.uri.queryParameters['ticket'])),
        GoRoute(path: '/learn-queue', builder: (_, _) => const LearnQueueScreen()),
        GoRoute(path: '/learn/:id', builder: (_, s) => LessonScreen(id: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/ci', builder: (_, _) => const CIFailuresScreen()),
        GoRoute(path: '/ci/:id', builder: (_, s) => CIFailureScreen(id: int.tryParse(s.pathParameters['id']!) ?? 0)),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => _Shell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/tickets', builder: (_, _) => const TicketsScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/tasks', builder: (_, _) => const TasksScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/analytics', builder: (_, _) => const AnalyticsScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())]),
          ],
        ),
      ],
    ],
  );
});

/// Says the account belongs in the other app, with a way to sign out.
class _WrongApp extends ConsumerWidget {
  const _WrongApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final adminApp = ref.watch(adminAppProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              HIcon(adminApp ? 'shield' : 'info', size: 40, color: c.ink3),
              const SizedBox(height: 14),
              Text(
                adminApp ? l.platformForbidden : l.mobileAdminAppOnly,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.4, color: c.ink),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => signOut(ref), child: Text(l.mobileSignOut)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The tab bar (.tabbar): five tabs with the demo's icons, the current one
/// in blue, and a red count on Home while something needs you.
class _Shell extends ConsumerWidget {
  const _Shell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final needs = ref.watch(dashboardProvider).value?.counts.needs ?? 0;
    return _TabScaffold(shell: shell, tabs: [
      ('dashboard', l.mobileHome, needs),
      ('all', l.navTickets, 0),
      ('tasks', l.navTasks, 0),
      ('analytics', l.navAnalytics, 0),
      ('more', l.mobileMore, 0),
    ]);
  }
}

/// The Admin cabinet's tab bar, with a count on Feedback while some is new.
class _AdminShell extends ConsumerWidget {
  const _AdminShell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fresh = ref.watch(platformFeedbackProvider).value?.where((f) => f.status == FeedbackStatusEnum.new_).length ?? 0;
    return _TabScaffold(shell: shell, tabs: [
      ('dashboard', l.platformNavDashboard, 0),
      ('repos', l.platformWorkspaces, 0),
      ('users', l.platformUsers, 0),
      ('feedback', l.feedbackAdminTitle, fresh),
      ('more', l.mobileMore, 0),
    ]);
  }
}

/// A shell's screens over the tab bar: (icon, label, badge) per tab.
class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.shell, required this.tabs});
  final StatefulNavigationShell shell;
  final List<(String, String, int)> tabs;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.line))),
        padding: EdgeInsets.fromLTRB(4, 6, 4, 6 + MediaQuery.paddingOf(context).bottom),
        child: Row(children: [
          for (final (i, (icon, label, badge)) in tabs.indexed)
            Expanded(
              child: _Tab(
                icon: icon,
                label: label,
                badge: badge,
                selected: i == shell.currentIndex,
                // Tapping the current tab again goes back to its first screen.
                onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              ),
            ),
        ]),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.label, required this.badge, required this.selected, required this.onTap});
  final String icon;
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final col = selected ? c.primary : c.ink3;
    return Semantics(
      selected: selected,
      button: true,
      label: badge > 0 ? '$label, $badge' : label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(clipBehavior: Clip.none, children: [
              HIcon(icon, size: 24, color: col, stroke: 1.8),
              if (badge > 0)
                Positioned(
                  left: 14,
                  top: -6,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.bad, borderRadius: BorderRadius.circular(9), border: Border.all(color: c.surface, width: 2)),
                    child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, height: 1)),
                  ),
                ),
            ]),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: col)),
          ]),
        ),
      ),
    );
  }
}
