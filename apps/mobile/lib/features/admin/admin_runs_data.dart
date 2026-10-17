import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart';

// Run history for the Admin cabinet: every Claude Code and Codex invocation
// across workspaces. Opening a transcript (or its prompt) is a read of
// customer content the server writes to the audit log, so those are fetched
// once per visit of the screen: never on a timer.

/// A ticket's stages, then the calls outside them, as the server names purposes.
const runStages = ['analyze', 'code', 'review', 'push', 'learn', 'preview', 'second_opinion'];
const runBackground = ['assistant', 'brief', 'detect', 'reflect', 'rules', 'translate'];

enum RunPeriod { day, week, month, all }

/// The list's filters. purpose is '' (all), 'stages', 'background' or one
/// purpose; status '' is any.
typedef RunQuery = ({int? workspace, String purpose, String status, bool stalled, RunPeriod period});

const RunQuery defaultRunQuery = (workspace: null, purpose: '', status: '', stalled: false, period: RunPeriod.week);

/// Invocations asked for at a time.
const runPage = 50;

/// When [p] starts, from [now]; null for all time.
DateTime? periodStart(RunPeriod p, DateTime now) => switch (p) {
  RunPeriod.day => now.subtract(const Duration(days: 1)),
  RunPeriod.week => now.subtract(const Duration(days: 7)),
  RunPeriod.month => now.subtract(const Duration(days: 30)),
  RunPeriod.all => null,
};

/// One page of the run history for [q], below [cursor] (null: the newest).
Future<RunHistoryPage> fetchRuns(AgntsApi api, RunQuery q, {String? cursor, DateTime? now}) async {
  final r = await api.getPlatformApi().listPlatformRuns(
    workspace: q.workspace,
    purpose: q.purpose.isEmpty ? null : q.purpose,
    status: q.status.isEmpty ? null : q.status,
    stalled: q.stalled ? true : null,
    from: periodStart(q.period, now ?? DateTime.now())?.toUtc(),
    cursor: cursor,
    limit: runPage,
  );
  return r.data ?? RunHistoryPage(items: const []);
}

/// The newest page for a filter; older pages are fetched with [fetchRuns].
final platformRunsProvider = FutureProvider.autoDispose.family<RunHistoryPage, RunQuery>((ref, q) => fetchRuns(requireApi(ref), q));

/// The totals for a filter.
final platformRunSummaryProvider = FutureProvider.autoDispose.family<RunHistorySummary, RunQuery>((ref, q) async {
  final r = await requireApi(ref).getPlatformApi().getPlatformRunSummary(
    workspace: q.workspace,
    purpose: q.purpose.isEmpty ? null : q.purpose,
    status: q.status.isEmpty ? null : q.status,
    stalled: q.stalled ? true : null,
    from: periodStart(q.period, DateTime.now())?.toUtc(),
  );
  return r.data!;
});

/// One transcript with its timeline. Audited: auto-disposed with the
/// screen, so each visit is one read.
final platformRunProvider = FutureProvider.autoDispose.family<RunTranscriptDetail, int>((ref, id) async {
  return (await requireApi(ref).getPlatformApi().getPlatformRun(id: id)).data!;
});

/// The prompt agnts sent; the screen watches it only once its tab is open. Audited.
final platformRunPromptProvider = FutureProvider.autoDispose.family<String, int>((ref, id) async {
  return (await requireApi(ref).getPlatformApi().getPlatformRunPrompt(id: id)).data?.prompt ?? '';
});

/// A purpose as the cabinet says it; one it does not know is shown as is.
String purposeLabel(AppLocalizations l, String p) => switch (p) {
  '' => l.runsAllPurposes,
  'stages' => l.runsPStages,
  'background' => l.runsPBackground,
  'analyze' => l.runsP_analyze,
  'code' => l.runsP_code,
  'review' => l.runsP_review,
  'push' => l.runsP_push,
  'learn' => l.runsP_learn,
  'preview' => l.runsP_preview,
  'second_opinion' => l.runsP_second_opinion,
  'assistant' => l.runsP_assistant,
  'brief' => l.runsP_brief,
  'detect' => l.runsP_detect,
  'reflect' => l.runsP_reflect,
  'rules' => l.runsP_rules,
  'translate' => l.runsP_translate,
  _ => p,
};

String statusLabel(AppLocalizations l, String s) => switch (s) {
  '' => l.runsAnyStatus,
  'running' => l.runsS_running,
  'done' => l.runsS_done,
  'error' => l.runsS_error,
  'timeout' => l.runsS_timeout,
  'cancelled' => l.runsS_cancelled,
  'oom' => l.runsS_oom,
  _ => s,
};

Tone statusTone(String s) => switch (s) {
  'running' => Tone.info,
  'done' => Tone.ok,
  'cancelled' => Tone.gray,
  'timeout' => Tone.warn,
  _ => Tone.bad,
};

/// Ended badly enough to tint the row.
bool runFailed(String s) => s == 'error' || s == 'timeout' || s == 'oom';

/// How long an invocation took, or has been running.
Duration runDuration(RunTranscript r, [DateTime? now]) {
  final d = (r.finishedAt ?? now ?? DateTime.now()).difference(r.startedAt);
  return d.isNegative ? Duration.zero : d;
}

/// What the row is about: the ticket, else the subject, else the workspace.
String runTitle(RunTranscript r) => (r.ticketKey?.isNotEmpty ?? false)
    ? r.ticketKey!
    : (r.subject?.isNotEmpty ?? false)
    ? r.subject!
    : r.workspace;

/// "mm:ss" (or "h:mm:ss") since the invocation started.
String clock(int ms) {
  final s = ms < 0 ? 0 : ms ~/ 1000;
  final h = s ~/ 3600;
  final mm = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
  final ss = (s % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// One row of the timeline: a tool call with its result, or a line.
sealed class RunItem {
  const RunItem(this.at, this.error);
  final int at;
  final bool error;
}

class ToolItem extends RunItem {
  ToolItem(this.call, this.result) : super(call.t, result?.error == true);
  final RunTranscriptEvent call;
  final RunTranscriptEvent? result;
}

class LineItem extends RunItem {
  LineItem(this.ev) : super(ev.t, (ev.k == 'result' || ev.k == 'tool_result') && ev.error == true);
  final RunTranscriptEvent ev;
}

/// Pairs each tool_result with its tool call (by id); a result whose call
/// was left out stays a line of its own.
List<RunItem> runTimeline(List<RunTranscriptEvent> events) {
  final results = <String, RunTranscriptEvent>{};
  final calls = <String>{};
  for (final e in events) {
    if (e.k == 'tool' && e.id != null) calls.add(e.id!);
    if (e.k == 'tool_result' && e.id != null) results.putIfAbsent(e.id!, () => e);
  }
  final out = <RunItem>[];
  for (final e in events) {
    if (e.k == 'tool') {
      out.add(ToolItem(e, e.id == null ? null : results[e.id]));
    } else if (e.k == 'tool_result' && e.id != null && calls.contains(e.id) && identical(results[e.id], e)) {
      continue;
    } else {
      out.add(LineItem(e));
    }
  }
  return out;
}

/// A tool input as text: pretty JSON, or as stored when it was too big.
String inputText(Object? input) {
  if (input == null) return '';
  if (input is String) return input;
  return const JsonEncoder.withIndent('  ').convert(input);
}

/// "42s", "6m 12s", "1h 4m": invocations are often under a minute.
String durText(Duration d) {
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
  return '${d.inSeconds}s';
}
