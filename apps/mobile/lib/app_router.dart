import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart' show FeedbackStatusEnum;

import 'core/data.dart';
import 'core/flavor.dart';
import 'core/session.dart';
import 'features/account/feedback_screen.dart';
import 'features/account/profile_screen.dart';
import 'features/account/workspaces_screen.dart';
import 'features/admin/admin_admins_screen.dart';
import 'features/admin/admin_audit_screen.dart';
import 'features/admin/admin_run_screen.dart';
import 'features/admin/admin_runs_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_data.dart';
import 'features/admin/admin_feedback_screen.dart';
import 'features/admin/admin_more_screen.dart';
import 'features/admin/admin_users_screen.dart';
import 'features/admin/admin_workspaces_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/assistant/assistant_screen.dart';
import 'features/assistant/assistant_stats.dart';
import 'features/assistant/code_screen.dart';
import 'features/auth/forgot_screen.dart';
import 'features/auth/invite_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/reset_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/verify_screen.dart';
import 'features/ci/ci_failure_screen.dart';
import 'features/ci/ci_screen.dart';
import 'features/documents/document_screen.dart';
import 'features/documents/documents_screen.dart';
import 'features/home/home_screen.dart';
import 'features/integrations/integration_screen.dart';
import 'features/integrations/integrations_screen.dart';
import 'features/learn/learn_queue.dart';
import 'features/meetings/call_screen.dart';
import 'features/meetings/meetings_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/learn/lesson_screen.dart';
import 'features/more/more_screen.dart';
import 'features/pulls/pull_screen.dart';
import 'features/repos/commit_screen.dart';
import 'features/repos/repo_screen.dart';
import 'features/repos/repos_screen.dart';
import 'features/reviews/reviews_screen.dart';
import 'features/rules/rules_screen.dart';
import 'features/settings/mcp_screen.dart';
import 'features/settings/networks_screen.dart';
import 'features/swagger/swagger_suites_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/tickets/api_results.dart';
import 'features/tickets/ticket_screen.dart';
import 'features/tickets/tickets_screen.dart';
import 'features/usage/usage_screen.dart';
import 'features/workspace/workspace_screen.dart';
import 'l10n/app_localizations.dart';
import 'main.dart' show signOut;
import 'theme.dart';
import 'widgets/ui.dart';

/// A screen opened over the tabs. go_router gives a route no transition of
/// its own unless it is a MaterialPage; this one slides in and, on iOS,
/// swipes back from anywhere on the page (theme.dart's pageTransitionsTheme).
GoRoute screenRoute(String path, Widget Function(BuildContext, GoRouterState) builder) => GoRoute(
  path: path,
  pageBuilder: (context, s) => MaterialPage<void>(key: s.pageKey, name: s.path, restorationId: s.pageKey.value, child: builder(context, s)),
);

/// Screens open without signing in.
const _publicPaths = ['/signup', '/forgot', '/reset-password', '/verify', '/invite'];

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
      // Signed out, only the account screens open; an emailed link
      // (verify, reset, invite) opens whether signed in or not.
      final public = _publicPaths.any((p) => at == p || at.startsWith('$p/'));
      if (!signedIn) return at == '/login' || public ? null : '/login';
      // An account in the wrong app: the admin app is for system Admins, and
      // an Admin account with no workspaces has nothing in the user app.
      final admin = ref.read(adminProvider);
      final wrong = admin != null && (adminApp ? !admin.admin : admin.only);
      if (wrong) return at == '/wrong-app' ? null : '/wrong-app';
      if (at == '/login' || at == '/wrong-app' || at == '/signup' || at == '/forgot') return home;
      return null;
    },
    routes: [
      screenRoute('/login', (_, _) => const LoginScreen()),
      screenRoute('/wrong-app', (_, _) => const _WrongApp()),
      screenRoute('/signup', (_, _) => const SignupScreen()),
      screenRoute('/forgot', (_, _) => const ForgotScreen()),
      screenRoute('/reset-password', (_, s) => ResetScreen(token: s.uri.queryParameters['token'] ?? '')),
      screenRoute('/verify', (_, s) => VerifyScreen(token: s.uri.queryParameters['token'])),
      screenRoute('/invite/:token', (_, s) => InviteScreen(token: s.pathParameters['token']!)),
      if (adminApp) ...[
        screenRoute('/admin/admins', (_, _) => const AdminAdminsScreen()),
        screenRoute('/admin/audit', (_, _) => const AdminAuditScreen()),
        screenRoute('/admin/runs', (_, _) => const AdminRunsScreen()),
        screenRoute('/admin/runs/:id', (_, s) => AdminRunScreen(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0)),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => _AdminShell(shell: shell),
          branches: [
            StatefulShellBranch(
              routes: [GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/admin/workspaces', builder: (_, _) => const AdminWorkspacesScreen())],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/admin/users',
                  builder: (_, s) => AdminUsersScreen(filter: s.uri.queryParameters['f']),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/admin/feedback', builder: (_, _) => const AdminFeedbackScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/admin/more', builder: (_, _) => const AdminMoreScreen())],
            ),
          ],
        ),
      ] else ...[
        // Notification taps deep-link here.
        screenRoute('/tickets/:key', (_, s) => TicketScreen(ticketKey: s.pathParameters['key']!)),
        screenRoute('/tickets/:key/api-results', (_, s) => ApiResultsScreen(ticketKey: s.pathParameters['key']!)),
        screenRoute('/repos/:id', (_, s) => RepoScreen(id: int.parse(s.pathParameters['id']!), name: s.uri.queryParameters['name'] ?? '')),
        screenRoute(
          '/repos/:id/commits/:sha',
          (_, s) => CommitScreen(repoId: int.parse(s.pathParameters['id']!), sha: s.pathParameters['sha']!),
        ),
        screenRoute(
          '/repos/:id/pulls/:number',
          (_, s) => PullScreen(repoId: int.parse(s.pathParameters['id']!), number: int.parse(s.pathParameters['number']!)),
        ),
        screenRoute('/repos', (_, _) => const ReposScreen()),
        screenRoute('/rules', (_, _) => const RulesScreen()),
        screenRoute('/documents', (_, _) => const DocumentsScreen()),
        screenRoute('/meetings', (_, _) => const MeetingsScreen()),
        // A meeting's call: from the list, a push, or a meeting link.
        screenRoute('/m/:code', (_, s) => CallScreen(code: s.pathParameters['code']!)),
        screenRoute('/documents/:id', (_, s) => DocumentScreen(id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0)),
        screenRoute('/reviews', (_, _) => const ReviewsScreen()),
        screenRoute('/swagger-suites', (_, _) => const SwaggerSuitesScreen()),
        screenRoute('/usage', (_, _) => const UsageScreen()),
        screenRoute('/integrations', (_, _) => const IntegrationsScreen()),
        screenRoute('/integrations/:provider', (_, s) => IntegrationScreen(provider: s.pathParameters['provider']!)),
        screenRoute('/networks', (_, s) => NetworksScreen(add: s.uri.queryParameters.containsKey('add'))),
        screenRoute('/mcp', (_, _) => const McpScreen()),
        screenRoute('/workspace', (_, s) => WorkspaceScreen(tab: s.uri.queryParameters['tab'])),
        screenRoute('/workspaces', (_, _) => const WorkspacesScreen()),
        screenRoute('/profile', (_, _) => const ProfileScreen()),
        screenRoute('/feedback', (_, _) => const FeedbackScreen()),
        screenRoute('/settings/appearance', (_, _) => const AppearancePage()),
        screenRoute('/settings/models', (_, _) => const DefaultModelsPage()),
        screenRoute('/settings/notifications', (_, _) => const NotificationsPage()),
        screenRoute('/learn', (_, s) => LearnScreen(ticketKey: s.uri.queryParameters['ticket'])),
        screenRoute('/learn-queue', (_, _) => const LearnQueueScreen()),
        screenRoute('/learn/:id', (_, s) => LessonScreen(id: int.parse(s.pathParameters['id']!))),
        // Prefilled from a Chat answer's offer (?text=…&repos=1,2) or a ticket (?ticket=KEY).
        screenRoute(
          '/assistant/code',
          (_, s) => CodeScreen(
            initialText: s.uri.queryParameters['text'],
            initialRepos: [
              for (final x in (s.uri.queryParameters['repos'] ?? '').split(','))
                if ((int.tryParse(x) ?? 0) > 0) int.parse(x),
            ],
            initialTicket: s.uri.queryParameters['ticket'],
          ),
        ),
        screenRoute('/assistant/code/:id', (_, s) => CodeScreen(conversationId: int.tryParse(s.pathParameters['id']!))),
        screenRoute('/assistant', (_, _) => const AssistantScreen()),
        screenRoute('/assistant-rated', (_, _) => const AssistantRatedScreen()),
        screenRoute('/assistant/:id', (_, s) => AssistantScreen(conversationId: int.tryParse(s.pathParameters['id']!))),
        screenRoute('/ci', (_, _) => const CIFailuresScreen()),
        screenRoute('/ci/:id', (_, s) => CIFailureScreen(id: int.tryParse(s.pathParameters['id']!) ?? 0)),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => _Shell(shell: shell),
          branches: [
            StatefulShellBranch(
              routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/tickets', builder: (_, _) => const TicketsScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/tasks', builder: (_, _) => const TasksScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/analytics', builder: (_, _) => const AnalyticsScreen())],
            ),
            StatefulShellBranch(
              routes: [GoRoute(path: '/more', builder: (_, _) => const MoreScreen())],
            ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HIcon(adminApp ? 'shield' : 'info', size: 40, color: c.ink3),
                const SizedBox(height: 14),
                Text(
                  adminApp ? l.platformForbidden : l.mobileAdminAppOnly,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4, color: c.ink),
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: () => signOut(ref), child: Text(l.mobileSignOut)),
              ],
            ),
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
    return _TabScaffold(
      shell: shell,
      tabs: [
        ('dashboard', l.mobileHome, needs),
        ('all', l.navTickets, 0),
        ('tasks', l.navTasks, 0),
        ('analytics', l.navAnalytics, 0),
        ('more', l.mobileMore, 0),
      ],
    );
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
    return _TabScaffold(
      shell: shell,
      tabs: [
        ('dashboard', l.platformNavDashboard, 0),
        ('repos', l.platformWorkspaces, 0),
        ('users', l.platformUsers, 0),
        ('feedback', l.feedbackAdminTitle, fresh),
        ('more', l.mobileMore, 0),
      ],
    );
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
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.line)),
        ),
        padding: EdgeInsets.fromLTRB(4, 6, 4, 6 + MediaQuery.paddingOf(context).bottom),
        child: Row(
          children: [
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
          ],
        ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
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
                        decoration: BoxDecoration(
                          color: c.bad,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: c.surface, width: 2),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, height: 1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: col),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
