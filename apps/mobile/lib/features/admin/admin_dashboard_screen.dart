import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../analytics/analytics_screen.dart' show BarChart, ChartLegend, ChartSeries;
import 'admin_data.dart';
import 'admin_widgets.dart';

/// The platform at a glance: people and workspaces, how fast they grow, and
/// what the server is running (the web's Admin dashboard).
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  static const _days = 30;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Runs and the queue change by the second; the web polls every 10s too.
    _tick = Timer.periodic(const Duration(seconds: 10), (_) => ref.invalidate(platformOverviewProvider));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final users = ref.watch(platformUsersProvider);
    final workspaces = ref.watch(platformWorkspacesProvider);
    final overview = ref.watch(platformOverviewProvider).value;

    Future<void> refresh() async {
      refreshPlatform(ref);
      await ref.read(platformUsersProvider.future);
    }

    final all = users.value ?? const <PlatformUser>[];
    // Users only: Admin accounts run the platform and are counted apart.
    final us = all.where((u) => u.user.isAdmin != true).toList();
    final ws = (workspaces.value ?? const <PlatformWorkspace>[]).where((w) => w.deletedAt == null).toList();
    final admins = all.where((u) => u.user.isAdmin == true).length;
    final cap = overview?.capacity;
    final recent = [...us]..sort((a, b) => (b.user.createdAt ?? DateTime(0)).compareTo(a.user.createdAt ?? DateTime(0)));

    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final labels = [for (var i = _days - 1; i >= 0; i--) DateFormat.MMMd(locale).format(DateTime(now.year, now.month, now.day - i))];

    Widget pad(Widget w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: w);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              PageHeader(title: l.platformNavDashboard, sub: l.platformCabinetBadge),
              if (users.hasError && all.isEmpty)
                pad(HCard(child: Text(l.mobileOffline)))
              else if (users.isLoading && all.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                pad(
                  Grid2(
                    children: [
                      KpiCard(
                        label: l.platformUsers,
                        value: '${us.length}',
                        note:
                            '${l.platformNewThisWeek('${us.where((u) => within(u.user.createdAt, 7)).length}')} · '
                            '${l.platformViaGoogle('${us.where((u) => !u.hasPassword).length}')}',
                        onTap: () => context.go('/admin/users'),
                      ),
                      KpiCard(
                        label: l.platformActiveUsers,
                        value: '${us.where((u) => within(u.lastSignInAt, 7)).length}',
                        note: l.platformActiveNote,
                        onTap: () => context.go('/admin/users?f=active'),
                      ),
                      KpiCard(
                        label: l.platformWorkspaces,
                        value: '${ws.length}',
                        note:
                            '${l.platformNewThisWeek('${ws.where((w) => within(w.createdAt, 7)).length}')} · '
                            '${l.platformTeams(ws.where((w) => w.members > 1).length)}',
                        onTap: () => context.go('/admin/workspaces'),
                      ),
                      KpiCard(
                        label: l.platformAdmins,
                        value: '$admins',
                        note: l.platformRunsNow(cap?.runs ?? 0),
                        onTap: () => context.push('/admin/admins'),
                      ),
                    ],
                  ),
                ),
                // Sign-ups per day
                SectionHeader(l.platformGrowthTitle),
                pad(
                  HCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.platformGrowthSub('$_days'), style: TextStyle(fontSize: 13, color: c.ink3)),
                        const SizedBox(height: 12),
                        BarChart(
                          series: [
                            ChartSeries(l.platformLegendUsers, perDay(us.map((u) => u.user.createdAt), _days), c.primary),
                            ChartSeries(l.platformLegendWorkspaces, perDay(ws.map((w) => w.createdAt), _days), c.warn),
                          ],
                          labels: labels,
                          maxLabels: 5,
                          height: 170,
                        ),
                        ChartLegend([(c.primary, l.platformLegendUsers), (c.warn, l.platformLegendWorkspaces)]),
                      ],
                    ),
                  ),
                ),
                // Newest accounts
                SectionHeader(
                  l.platformRecentTitle,
                  trailing: GestureDetector(
                    onTap: () => context.go('/admin/users'),
                    child: Text(l.platformSeeAll, style: TextStyle(color: c.primary)),
                  ),
                ),
                pad(
                  recent.isEmpty
                      ? HCard(
                          child: Text(l.platformNoUsers, style: TextStyle(color: c.ink3)),
                        )
                      : ListGroup(
                          children: [
                            for (final u in recent.take(6))
                              PersonRow(
                                user: u.user,
                                sub: contactOf(u.user),
                                trailing: Text(agoText(context, u.user.createdAt), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                              ),
                          ],
                        ),
                ),
                // The server: memory, runs, disk
                SectionHeader(
                  l.platformCapacity,
                  trailing: (cap?.full ?? false) ? ToneBadge(l.platformFull, Tone.warn, small: true) : null,
                ),
                pad(
                  cap == null
                      ? const HCard(child: LoadLine())
                      : Grid2(
                          children: [
                            Fact(
                              l.platformReserved,
                              cap.budgetMb > 0
                                  ? '${gb(cap.reservedMb)} / ${gb(cap.budgetMb)}'
                                  : '${gb(cap.reservedMb)} (${l.platformBudgetNone})',
                            ),
                            Fact(l.platformRuns, '${cap.runs}'),
                            if (cap.diskFreeMb != null) Fact(l.platformDisk, gb(cap.diskFreeMb!)),
                          ],
                        ),
                ),
                // Running now
                SectionHeader(l.platformRunning),
                pad(
                  (overview?.runs ?? const []).isEmpty
                      ? HCard(
                          child: Text(l.platformNoRuns, style: TextStyle(color: c.ink3)),
                        )
                      : ListGroup(
                          children: [
                            for (final r in overview!.runs)
                              ListRow(
                                title: r.ticketKey,
                                subtitle: '${r.workspace ?? '—'} · ${r.stage}',
                                trailing: Text(agoText(context, r.startedAt), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                              ),
                          ],
                        ),
                ),
                // Waiting for the server
                SectionHeader(l.platformQueue),
                pad(
                  (overview?.serverQueue ?? const []).isEmpty
                      ? HCard(
                          child: Text(l.platformNoQueue, style: TextStyle(color: c.ink3)),
                        )
                      : ListGroup(
                          children: [
                            for (final (i, q) in overview!.serverQueue.indexed)
                              ListRow(
                                leading: Text(
                                  '#${i + 1}',
                                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink3),
                                ),
                                title: q.ticketKey,
                                subtitle: q.workspace,
                              ),
                          ],
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
