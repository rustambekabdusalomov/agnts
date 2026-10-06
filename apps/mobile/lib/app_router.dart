import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/session.dart';
import 'core/data.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/auth/login_screen.dart';
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
import 'theme.dart';
import 'widgets/ui.dart';

/// Rebuilds the router's redirect when the session changes.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionListenable(ref);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final s = ref.read(sessionProvider);
      if (s.isLoading) return null;
      final signedIn = s.value != null;
      final atLogin = state.matchedLocation == '/login';
      if (!signedIn) return atLogin ? null : '/login';
      if (atLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      // Notification taps deep-link here.
      GoRoute(path: '/tickets/:key', builder: (_, s) => TicketScreen(ticketKey: s.pathParameters['key']!)),
      GoRoute(
        path: '/repos/:id',
        builder: (_, s) => RepoScreen(id: int.parse(s.pathParameters['id']!), name: s.uri.queryParameters['name'] ?? ''),
      ),
      GoRoute(path: '/learn', builder: (_, s) => LearnScreen(ticketKey: s.uri.queryParameters['ticket'])),
      GoRoute(path: '/learn-queue', builder: (_, _) => const LearnQueueScreen()),
      GoRoute(path: '/learn/:id', builder: (_, s) => LessonScreen(id: int.parse(s.pathParameters['id']!))),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/tickets', builder: (_, __) => const TicketsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/more', builder: (_, __) => const MoreScreen())]),
        ],
      ),
    ],
  );
});

/// The tab bar (.tabbar): five tabs with the demo's icons, the current one
/// in blue, and a red count on Home while something needs you.
class _Shell extends ConsumerWidget {
  const _Shell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final needs = ref.watch(dashboardProvider).value?.counts.needs ?? 0;
    final tabs = [
      ('dashboard', l.mobileHome, needs),
      ('all', l.navTickets, 0),
      ('tasks', l.navTasks, 0),
      ('analytics', l.navAnalytics, 0),
      ('more', l.mobileMore, 0),
    ];
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
