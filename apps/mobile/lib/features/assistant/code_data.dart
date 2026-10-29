import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import 'assistant_data.dart';

// The chat's Code mode: conversations that drive tickets. The timeline is
// the person's messages and the tickets' events; the live stream refreshes
// it on code_message and code_approval, and the screen adds the tickets'
// own events as they come.

/// A Code conversation with its timeline and the tool calls waiting for the
/// person's decision.
final codeTimelineProvider = FutureProvider.family<CodeTimeline, int>((ref, id) async {
  return (await requireApi(ref).getAssistantApi().getCodeTimeline(conversationId: id)).data!;
});

/// Called by the live stream for every code_* event.
void onCodeEvent(Ref ref, Map<String, dynamic> e) {
  final data = e['data'];
  final conv = data is Map ? (data['conversation_id'] as num?)?.toInt() : null;
  if (conv != null && conv > 0) ref.invalidate(codeTimelineProvider(conv));
  ref.invalidate(assistantConversationsProvider);
}

/// The ticket events a Code conversation shows (as the server's CodeTimelineTypes).
const codeTimelineTypes = {
  'state_changed',
  'ticket_created',
  'claude_text',
  'claude_tool',
  'check',
  'answered',
  'feedback',
  'pushed',
  'pr_opened',
  'pr_merged',
  'error',
  'rate_limit',
  'review_done',
  'review_ready',
  'queued',
  'guard',
  'checkpoint',
  'budget',
  'kind_changed',
};

/// The ticket new messages go to, or null.
CodeTicket? currentTicket(AssistantConversation? c) {
  final ts = c?.tickets ?? const <CodeTicket>[];
  for (var i = ts.length - 1; i >= 0; i--) {
    if (ts[i].current) return ts[i];
  }
  return null;
}

/// Whether a stage of a ticket in state [s] is running: messages wait for it.
bool codeRunning(TicketState? s) =>
    s == TicketState.new_ || s == TicketState.analyzing || s == TicketState.coding || s == TicketState.testing || s == TicketState.pushing;

/// Messages still waiting for the current ticket's run.
List<AssistantMessage> codeQueued(AssistantConversation? c) {
  final key = currentTicket(c)?.key;
  return [
    for (final m in c?.messages ?? const <AssistantMessage>[])
      if (m.routed == CodeRouted.queued && m.ticketKey == key) m,
  ];
}

/// A block of the timeline: a message, a run (the agent's texts with its
/// tool calls folded into steps), or a one-line note of what the ticket did.
sealed class CodeBlock {
  const CodeBlock();
}

class CodeMessageBlock extends CodeBlock {
  const CodeMessageBlock(this.message);
  final AssistantMessage message;
}

class CodeRunBlock extends CodeBlock {
  CodeRunBlock(this.ticketKey);
  final String ticketKey;
  final parts = <Object>[]; // an Event (text) or a List<Event> (tool calls)
}

class CodeLineBlock extends CodeBlock {
  const CodeLineBlock(this.event);
  final Event event;
}

bool _hidden(Event e) {
  if (e.type == 'budget' || e.type == 'ticket_created' || e.type == 'rate_limit') return true;
  // The person's own words, which their message already shows.
  return (e.type == 'feedback' || e.type == 'answered') && e.origin == EventOriginEnum.assistant;
}

/// Groups a timeline into blocks, in order.
List<CodeBlock> codeBlocks(List<TimelineItem> items) {
  final out = <CodeBlock>[];
  for (final it in items) {
    final m = it.message;
    if (m != null) {
      out.add(CodeMessageBlock(m));
      continue;
    }
    final e = it.event;
    if (e == null || _hidden(e)) continue;
    if (e.type != 'claude_text' && e.type != 'claude_tool') {
      out.add(CodeLineBlock(e));
      continue;
    }
    var run = out.isEmpty ? null : out.last;
    if (run is! CodeRunBlock || run.ticketKey != e.ticketKey) {
      run = CodeRunBlock(e.ticketKey);
      out.add(run);
    }
    if (e.type == 'claude_text') {
      if (e.message.trim().isNotEmpty) run.parts.add(e);
    } else if (run.parts.isNotEmpty && run.parts.last is List<Event>) {
      (run.parts.last as List<Event>).add(e);
    } else {
      run.parts.add(<Event>[e]);
    }
  }
  return out;
}

/// Live events of the conversation's tickets newer than the timeline, as items.
List<TimelineItem> codeLiveItems(List<TimelineItem> timeline, List<Event> events, Set<String> keys) {
  var newest = 0;
  for (final it in timeline) {
    final id = it.event?.id ?? 0;
    if (id > newest) newest = id;
  }
  final seen = <int>{};
  return [
    for (final e in events)
      if (e.id > newest && keys.contains(e.ticketKey) && codeTimelineTypes.contains(e.type) && seen.add(e.id))
        TimelineItem(at: e.createdAt, event: e),
  ];
}

/// What a message did, in words.
String routedLabel(AppLocalizations l, AssistantMessage m) {
  final key = m.ticketKey ?? '';
  return switch (m.routed) {
    CodeRouted.created => l.codechatRoutedCreated(key),
    CodeRouted.answered => l.codechatRoutedAnswered(key),
    CodeRouted.changes => l.codechatRoutedChanges(key),
    CodeRouted.continued => l.codechatRoutedContinued(key),
    CodeRouted.retried => l.codechatRoutedRetried(key),
    CodeRouted.queued => l.codechatRoutedQueued(key),
    CodeRouted.sent => l.codechatRoutedSent(key),
    CodeRouted.failed => l.codechatRoutedFailed(m.error ?? ''),
    CodeRouted.steered => l.codechatRoutedSteered,
    null => '',
  };
}

/// What the composer asks for, by the current ticket's state.
String codePlaceholder(AppLocalizations l, TicketState? s) => switch (s) {
  null => l.codechatPlaceholderNew,
  TicketState.waitingForReview => l.codechatPlaceholderReview,
  TicketState.waitingForAnswers => l.codechatPlaceholderAnswers,
  TicketState.failed || TicketState.rateLimited => l.codechatPlaceholderStopped,
  TicketState.pushing => l.codechatPlaceholderPushing,
  TicketState.done || TicketState.rejected => l.codechatPlaceholderDone,
  _ => l.codechatPlaceholderRunning,
};

/// A done or rejected ticket changed lists elsewhere: refresh them.
void refreshAfterDecision(void Function(ProviderOrFamily) invalidate, String key) {
  invalidate(dashboardProvider);
  invalidate(queueProvider);
  invalidate(ticketsProvider);
  invalidate(ticketProvider(key));
}

final _nameChar = RegExp(r'[a-z0-9\-_./]');
bool _isNameChar(String ch) => _nameChar.hasMatch(ch.toLowerCase());

/// The repositories a message names, as the server reads it
/// (domain.MentionedRepos): "@name" always, and with [plain] the name
/// alone as a word. Matching ignores case; owner/name also answers to name.
List<int> mentionedRepos(String text, List<Repository> repos, {required bool plain}) {
  final words = <String>{};
  final tagged = <String>{};
  final low = text.toLowerCase();
  for (var i = 0; i < low.length;) {
    if (!_isNameChar(low[i])) {
      i++;
      continue;
    }
    var j = i;
    while (j < low.length && _isNameChar(low[j])) {
      j++;
    }
    final w = low.substring(i, j).replaceFirst(RegExp(r'\.+$'), '');
    words.add(w);
    if (i > 0 && low[i - 1] == '@') tagged.add(w);
    i = j;
  }
  return [
    for (final r in repos)
      if (_names(r.name).any((n) => tagged.contains(n) || (plain && words.contains(n)))) r.id,
  ];
}

List<String> _names(String name) {
  final n = name.toLowerCase();
  final k = n.lastIndexOf('/');
  return k >= 0 && k < n.length - 1 ? [n, n.substring(k + 1)] : [n];
}

/// The @mention being typed at [caret]: where its @ is and what follows it.
({int start, String query})? mentionAt(String text, int caret) {
  // The caret may lag a text that was just cleared or replaced.
  caret = caret.clamp(0, text.length);
  var i = caret;
  while (i > 0 && _isNameChar(text[i - 1])) {
    i--;
  }
  if (i == 0 || text[i - 1] != '@') return null;
  // An @ inside a word is an e-mail address, not a mention.
  if (i > 1 && _isNameChar(text[i - 2])) return null;
  return (start: i - 1, query: text.substring(i, caret));
}

/// The repositories to offer for a mention's [query]: names that start with it first.
List<Repository> mentionOptions(String query, List<Repository> repos, {int max = 6}) {
  final q = query.toLowerCase();
  final starts = repos.where((r) => r.name.toLowerCase().startsWith(q));
  final inside = repos.where((r) => !r.name.toLowerCase().startsWith(q) && r.name.toLowerCase().contains(q));
  return [...starts, ...inside].take(max).toList();
}

/// [text] with the mention from [start] to [caret] replaced by @name and a
/// space, and where the caret goes.
({String text, int caret}) insertMention(String text, int start, int caret, String name) {
  final tag = '@$name ';
  final rest = text.substring(caret).replaceFirst(RegExp(r'^\S*'), '').replaceFirst(RegExp(r'^ '), '');
  return (text: text.substring(0, start) + tag + rest, caret: start + tag.length);
}
