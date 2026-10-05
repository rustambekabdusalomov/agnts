import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiro_api/hiro_api.dart';

import 'api.dart';

// Server data. The live stream (live.dart) invalidates these as events arrive.

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
