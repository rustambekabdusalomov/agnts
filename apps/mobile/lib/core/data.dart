import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import 'api.dart';
import 'session.dart';

// Server data. The live stream (live.dart) invalidates these as events arrive.

/// The signed-in user with the workspaces they belong to.
final meProvider = FutureProvider<User>((ref) async {
  return (await requireApi(ref).getAuthApi().getMe()).data!;
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
