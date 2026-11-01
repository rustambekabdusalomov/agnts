import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import 'api.dart';
import 'session.dart';

// Server data. The live stream (live.dart) invalidates these as events arrive.

/// The signed-in user with the workspaces they belong to.
final meProvider = FutureProvider<User>((ref) async {
  return (await requireApi(ref).getAuthApi().getMe()).data!;
});

/// Whether the person is a system Admin (`admin`), and an Admin account
/// with no workspaces (`only`), whose home is the Admin cabinet. Null until
/// the account has loaded.
final adminProvider = Provider<({bool admin, bool only})?>((ref) {
  final me = ref.watch(meProvider).value;
  if (me == null) return null;
  final admin = me.isAdmin ?? false;
  return (admin: admin, only: admin && (me.workspaces?.isEmpty ?? true));
});

/// The workspace the app acts in: the chosen one, else the server's (the
/// one opened last). Null while loading, or when the user has none.
final currentWorkspaceProvider = Provider<WorkspaceSummary?>((ref) {
  final me = ref.watch(meProvider).value;
  final ws = me?.workspaces ?? const <WorkspaceSummary>[];
  if (ws.isEmpty) return null;
  final slug = ref.watch(sessionProvider.select((s) => s.value?.workspace)) ?? me?.lastWorkspace;
  return ws.firstWhere((w) => w.slug == slug, orElse: () => ws.first);
});

/// Whether the person may change the current workspace: viewers only look.
final canEditProvider = Provider<bool>((ref) => ref.watch(currentWorkspaceProvider)?.role != WorkspaceRole.viewer);

/// The workspace's runs and slots, and where its tickets wait.
final queueProvider = FutureProvider<QueueStatus>((ref) async {
  return (await requireApi(ref).getWorkspaceApi().getQueue()).data!;
});

final dashboardProvider = FutureProvider<Dashboard>((ref) async {
  return (await requireApi(ref).getDashboardApi().getDashboard()).data!;
});

final usageProvider = FutureProvider<Usage>((ref) async {
  return (await requireApi(ref).getUsageApi().getUsage()).data!;
});

final settingsProvider = FutureProvider<Settings>((ref) async {
  return (await requireApi(ref).getSettingsApi().getSettings()).data!;
});

/// Tickets filtered by state ("" = all).
final ticketsProvider = FutureProvider.family<List<Ticket>, String>((ref, filter) async {
  final states = filterStates[filter] ?? const <TicketState>[];
  final res = await requireApi(ref).getTicketsApi().listTickets(state: states.isEmpty ? null : states);
  return res.data ?? const [];
});

final ticketProvider = FutureProvider.family<TicketDetail, String>((ref, key) async {
  return (await requireApi(ref).getTicketsApi().getTicket(key: key)).data!;
});

final ticketEventsProvider = FutureProvider.family<List<Event>, String>((ref, key) async {
  final res = await requireApi(ref).getTicketsApi().listTicketEvents(key: key, limit: 1000);
  return res.data ?? const [];
});

final reposProvider = FutureProvider<List<Repository>>((ref) async {
  return (await requireApi(ref).getReposApi().listRepos()).data ?? const [];
});

/// Repository groups: a task can start in all of a group's repositories.
final repoGroupsProvider = FutureProvider<List<RepoGroup>>((ref) async {
  return (await requireApi(ref).getReposApi().listRepoGroups()).data ?? const [];
});

final integrationsProvider = FutureProvider<List<Integration>>((ref) async {
  return (await requireApi(ref).getIntegrationsApi().listIntegrations()).data ?? const [];
});

/// Global activity log; type is all, user or problems.
final activityProvider = FutureProvider.family<List<Event>, String>((ref, type) async {
  final res = await requireApi(ref).getLogsApi().listEvents(type: type, limit: 100);
  return res.data?.events ?? const [];
});

const filterStates = <String, List<TicketState>>{
  'needs': [TicketState.waitingForAnswers, TicketState.waitingForReview, TicketState.failed, TicketState.rateLimited],
  'running': [TicketState.analyzing, TicketState.coding, TicketState.testing, TicketState.pushing],
  'queue': [TicketState.new_],
  'done': [TicketState.done, TicketState.rejected],
  'all': [],
};

/// Lessons by status: new, learned or all.
final lessonsProvider = FutureProvider.family<LessonList, String>((ref, status) async {
  return (await requireApi(ref).getLearnApi().listLessons(status: status)).data!;
});

/// Lessons a ticket's change taught.
final ticketLessonsProvider = FutureProvider.family<LessonList, String>((ref, key) async {
  return (await requireApi(ref).getLearnApi().listLessons(ticket: key)).data!;
});

/// Done tickets and their learn status (running, queued, failed, never).
final learnQueueProvider = FutureProvider<List<LearnQueueItem>>((ref) async {
  return (await requireApi(ref).getLearnApi().getLearnQueue()).data ?? const [];
});

final lessonProvider = FutureProvider.family<Lesson, int>((ref, id) async {
  return (await requireApi(ref).getLearnApi().getLesson(id: id)).data!;
});

final analyticsProvider = FutureProvider<Analytics>((ref) async {
  return (await requireApi(ref).getAnalyticsApi().getAnalytics(days: 7)).data!;
});

/// What each CI failures filter shows: red (still failing), flaky, or all.
const ciFilterStatuses = <String, List<CIStatus>>{
  'red': [CIStatus.triage, CIStatus.open, CIStatus.fixing, CIStatus.regression],
  'flaky': [CIStatus.flaky],
  'all': [],
};

/// CI failure groups for a filter (red, flaky or all), newest first.
final ciFailuresProvider = FutureProvider.family<List<CIFailure>, String>((ref, filter) async {
  final statuses = ciFilterStatuses[filter] ?? const <CIStatus>[];
  final res = await requireApi(ref).getCiApi().listCIFailures(status: statuses.isEmpty ? null : statuses.map((s) => s.value).join(','));
  return res.data ?? const [];
});

/// One CI failure group with its redacted log excerpt.
final ciFailureProvider = FutureProvider.family<CIFailure, int>((ref, id) async {
  return (await requireApi(ref).getCiApi().getCIFailure(failureId: id)).data!;
});

/// Log watcher findings of a category (error, security) that need
/// attention.
final logFindingsProvider = FutureProvider.family<List<LogFinding>, String>((ref, category) async {
  final res = await requireApi(ref).getLogsApi().listLogFindings(category: category, active: true);
  return res.data ?? const [];
});

/// One log finding with its redacted excerpt.
final logFindingProvider = FutureProvider.family<LogFinding, int>((ref, id) async {
  return (await requireApi(ref).getLogsApi().getLogFinding(findingId: id)).data!;
});

/// The CI failure a ticket fixes; null when it has none (404).
final ticketCIProvider = FutureProvider.family<CIFailure?, String>((ref, key) async {
  try {
    return (await requireApi(ref).getCiApi().getTicketCIFailure(key: key)).data;
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return null;
    rethrow;
  }
});

/// A Swagger test's latest results (without the request bodies).
final apiResultsProvider = FutureProvider.family<SwaggerResults, String>((ref, key) async {
  return (await requireApi(ref).getSwaggerApi().getApiResults(key: key)).data!;
});
