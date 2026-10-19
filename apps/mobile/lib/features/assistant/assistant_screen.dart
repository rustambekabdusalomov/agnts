import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../core/data.dart' show canEditProvider;
import '../repos/manage_widgets.dart' show confirmAction;
import '../tickets/kinds.dart' show ReportMarkdown;
import 'assistant_data.dart';
import 'conversations_sheet.dart';

const _maxQuestion = 1000;

/// The assistant: a chat about the workspace. Questions are typed; answers
/// come from a snapshot of the workspace in 10-30 seconds and link the
/// tickets, CI failures and lessons they name. Asked to act, an answer
/// carries the actions as cards; nothing happens until the person confirms.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key, this.conversationId});
  final int? conversationId;

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _text = TextEditingController();
  int? _id;
  bool _sending = false;
  Timer? _poll; // fetches the conversation while an answer is open
  Timer? _tick; // redraws the "thinking" seconds

  @override
  void initState() {
    super.initState();
    _id = widget.conversationId;
  }

  @override
  void dispose() {
    _poll?.cancel();
    _tick?.cancel();
    _text.dispose();
    super.dispose();
  }

  /// Polls and ticks while an answer is being made, and stops after.
  void _follow(bool open) {
    if (open && _poll == null) {
      _poll = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_id != null) ref.invalidate(assistantConversationProvider(_id!));
      });
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!open && _poll != null) {
      _poll?.cancel();
      _tick?.cancel();
      _poll = _tick = null;
    }
  }

  Future<void> _send([String? question]) async {
    final l = AppLocalizations.of(context);
    final q = (question ?? _text.text).trim();
    if (q.isEmpty || q.length > _maxQuestion || _sending) return;
    setState(() => _sending = true);
    final api = ref.read(apiProvider)!.getAssistantApi();
    final ask = AssistantAsk(question: q, lang: assistantLanguage(ref, context));
    try {
      final res = _id == null
          ? await api.startAssistantConversation(assistantAsk: ask)
          : await api.askAssistant(conversationId: _id!, assistantAsk: ask);
      final c = res.data!;
      if (question == null) _text.clear();
      setState(() => _id = c.id);
      ref.invalidate(assistantConversationProvider(c.id));
      ref.invalidate(assistantConversationsProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _history() async {
    final picked = await showConversationsSheet(context, current: _id);
    if (!mounted || picked == null) return;
    setState(() => _id = picked == 0 ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final conv = _id == null ? null : ref.watch(assistantConversationProvider(_id!));
    final messages = conv?.value?.messages ?? const <AssistantMessage>[];
    final open = messages.any(isOpen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _follow(open);
    });

    Widget body;
    if (_id == null) {
      body = _Empty(onAsk: _send);
    } else if (conv!.hasError && messages.isEmpty) {
      body = EmptyState(title: l.mobileOffline);
    } else if (messages.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      // Newest at the bottom, kept in view as answers arrive.
      final rev = messages.reversed.toList();
      body = ListView.builder(
        reverse: true,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        itemCount: rev.length,
        itemBuilder: (context, i) {
          final m = rev[i];
          if (m.role == AssistantMessageRoleEnum.user) return _Question(m.text);
          // The question an answer belongs to, to ask again.
          final q = i + 1 < rev.length && rev[i + 1].role == AssistantMessageRoleEnum.user ? rev[i + 1].text : null;
          return _Answer(m, onAskAgain: q == null ? null : () => _send(q));
        },
      );
    }

    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: l.massistantTitle,
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        actions: [
          IconButton(tooltip: l.massistantHistory, onPressed: _history, icon: HIcon('logs', size: 22, color: c.primary)),
          if (_id != null)
            IconButton(
              tooltip: l.massistantNewConversation,
              onPressed: () => setState(() => _id = null),
              icon: HIcon('plus', size: 22, color: c.primary),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Expanded(child: body),
          _InputBar(controller: _text, sending: _sending, onSend: () => _send()),
        ]),
      ),
    );
  }
}

/// The start of a conversation: what the assistant does and questions to tap.
class _Empty extends ConsumerWidget {
  const _Empty({required this.onAsk});
  final void Function(String) onAsk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final suggestions = [
      l.massistantSuggestWaiting,
      l.massistantSuggestCi,
      l.massistantSuggestSpend,
      l.massistantSuggestDone,
      if (ref.watch(canEditProvider)) l.massistantSuggestAct,
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 24, 16, 16), children: [
      Center(child: HIcon('assistant', size: 40, color: c.primary)),
      EmptyState(title: l.massistantEmptyTitle, text: l.massistantEmptyText),
      Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
        for (final s in suggestions)
          ActionChip(
            label: Text(s),
            onPressed: () => onAsk(s),
            backgroundColor: c.surface,
            side: BorderSide(color: c.line),
            labelStyle: TextStyle(color: c.ink, fontSize: 14),
          ),
      ]),
      const SizedBox(height: 24),
      Text(l.massistantPrivate, textAlign: TextAlign.center, style: TextStyle(color: c.ink3, fontSize: 13)),
    ]);
  }
}

class _Question extends StatelessWidget {
  const _Question(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(18)),
        child: SelectableText(text, style: TextStyle(fontSize: 15, height: 1.4, color: c.primaryInk)),
      ),
    );
  }
}

/// An answer: thinking (with seconds and what it reads), failed (with a way
/// to ask again), or the Markdown answer with the actions it proposes, its
/// links and a rating.
class _Answer extends ConsumerWidget {
  const _Answer(this.m, {this.onAskAgain});
  final AssistantMessage m;
  final VoidCallback? onAskAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    Widget child;
    if (isOpen(m)) {
      final live = ref.watch(assistantLiveProvider)[m.id];
      final secs = DateTime.now().difference(m.createdAt.toLocal()).inSeconds.clamp(0, 999);
      child = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.only(top: 3), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.massistantThinking('$secs'), style: TextStyle(fontSize: 15, color: c.ink2, fontWeight: FontWeight.w700)),
            if (live?.file != null && live?.text == null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(l.massistantReading(fileLabel(l, live!.file!)), style: TextStyle(fontSize: 13.5, color: c.ink3)),
              ),
          ]),
        ),
      ]);
      // The answer as the run says it, before it is stored.
      if (live?.text != null) {
        child = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          child,
          const SizedBox(height: 8),
          Opacity(opacity: 0.6, child: ReportMarkdown(live!.text!)),
        ]);
      }
    } else if (m.status == AssistantMessageStatusEnum.failed) {
      child = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.massistantFailed, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.badInk)),
        if (m.error != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(m.error!, style: TextStyle(fontSize: 14, color: c.ink2))),
        if (onAskAgain != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextButton(onPressed: onAskAgain, child: Text(l.massistantAskAgain)),
          ),
      ]);
    } else {
      child = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ReportMarkdown(m.text),
        for (final a in m.actions ?? const <AssistantAction>[]) _ActionCard(a, key: ValueKey(a.id)),
        for (final e in m.actionErrors ?? const <String>[])
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l.massistantActionNotOffered(e), style: TextStyle(fontSize: 13, color: c.ink3)),
          ),
        if (m.links.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final link in m.links) _LinkChip(link)]),
        ],
        const SizedBox(height: 6),
        _Footer(m),
      ]);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10, right: 24),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.line)),
        child: child,
      ),
    );
  }
}

/// What the assistant reads, in words: "ci.json" -> "CI failures".
String fileLabel(AppLocalizations l, String file) {
  if (file.startsWith('ticket-')) return l.massistantFileTicket(file.substring(7).replaceAll('.json', ''));
  if (file.startsWith('ci')) return l.massistantFileCi;
  return switch (file) {
    'inbox.json' => l.massistantFileInbox,
    'tickets.json' => l.massistantFileTickets,
    'usage.json' => l.massistantFileUsage,
    'analytics.json' => l.massistantFileAnalytics,
    'repositories.json' => l.massistantFileRepos,
    'groups.json' => l.massistantFileGroups,
    'me.json' => l.massistantFileMe,
    'lessons.json' => l.massistantFileLessons,
    'conversation.json' => l.massistantFileConversation,
    'question.txt' => l.massistantFileQuestion,
    _ => l.massistantFileOther,
  };
}

/// An action an answer proposes: agnts's summary of what it does, and
/// Confirm and Decline while it waits; then what became of it. Approve and
/// reject ask once more before they run.
class _ActionCard extends ConsumerStatefulWidget {
  const _ActionCard(this.a, {super.key});
  final AssistantAction a;

  @override
  ConsumerState<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends ConsumerState<_ActionCard> {
  bool _busy = false;

  Future<void> _decide(bool confirm) async {
    final l = AppLocalizations.of(context);
    final a = widget.a;
    if (confirm && a.destructive) {
      final ok = await confirmAction(context,
          title: l.massistantActionConfirmTitle,
          message: l.massistantActionConfirmText(a.summary),
          confirmLabel: l.massistantActionConfirm,
          danger: true);
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await decideAction(ref, a, confirm: confirm);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final a = widget.a;
    final waits = actionWaits(a);
    final status = a.status == AssistantActionStatusEnum.proposed && !waits ? AssistantActionStatusEnum.expired : a.status;
    Widget outcome(IconData icon, Color color, String label, String? result) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: label, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
              if (result != null && result.isNotEmpty) TextSpan(text: ' · $result', style: TextStyle(color: c.ink2)),
            ])),
          ),
        ]);
    final Widget foot = switch (status) {
      AssistantActionStatusEnum.proposed => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.massistantActionHint, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: _busy ? null : () => _decide(false), child: Text(l.massistantActionDecline)),
            const SizedBox(width: 6),
            FilledButton(
              style: a.destructive ? FilledButton.styleFrom(backgroundColor: c.bad, foregroundColor: Colors.white) : null,
              onPressed: _busy ? null : () => _decide(true),
              child: _busy
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.massistantActionConfirm),
            ),
          ]),
        ]),
      AssistantActionStatusEnum.running => Row(children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(l.massistantActionRunning, style: TextStyle(color: c.ink2)),
        ]),
      AssistantActionStatusEnum.done => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          outcome(Icons.check_circle_outline, c.okInk, l.massistantActionDone, a.result),
          if (a.ticketKey != null && a.ticketKey!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _LinkChip(AssistantLink(kind: AssistantLinkKindEnum.ticket, key: a.ticketKey)),
            ),
        ]),
      AssistantActionStatusEnum.failed => outcome(Icons.error_outline, c.badInk, l.massistantActionFailed, a.result),
      AssistantActionStatusEnum.cancelled => Text(l.massistantActionCancelled, style: TextStyle(color: c.ink3)),
      AssistantActionStatusEnum.expired => Text(l.massistantActionExpired, style: TextStyle(color: c.ink3)),
    };
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: waits && a.destructive ? c.bad.withValues(alpha: 0.5) : c.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Opacity(
          opacity: waits || status == AssistantActionStatusEnum.done || status == AssistantActionStatusEnum.running ? 1 : 0.6,
          child: SelectableText(a.summary, style: TextStyle(fontSize: 14.5, height: 1.4, color: c.ink)),
        ),
        const SizedBox(height: 8),
        foot,
      ]),
    );
  }
}

/// A link to a ticket, a CI failure or a lesson.
class _LinkChip extends StatelessWidget {
  const _LinkChip(this.link);
  final AssistantLink link;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (label, route) = switch (link.kind) {
      AssistantLinkKindEnum.ticket => (link.key ?? '', '/tickets/${link.key}'),
      AssistantLinkKindEnum.ci => (l.massistantLinkCi('${link.id}'), '/ci/${link.id}'),
      AssistantLinkKindEnum.lesson => (l.massistantLinkLesson('${link.id}'), '/learn/${link.id}'),
    };
    return ActionChip(
      avatar: HIcon(link.kind == AssistantLinkKindEnum.ticket ? 'tasks' : (link.kind == AssistantLinkKindEnum.ci ? 'running' : 'learn'),
          size: 16, color: c.primaryInk),
      label: Text(label, style: TextStyle(fontFamily: link.kind == AssistantLinkKindEnum.ticket ? AgntsFonts.mono : null, fontSize: 13.5)),
      backgroundColor: c.primarySoft,
      side: BorderSide.none,
      labelStyle: TextStyle(color: c.primaryInk),
      onPressed: () => context.push(route),
    );
  }
}

/// How long the answer took, and thumbs up and down.
class _Footer extends ConsumerWidget {
  const _Footer(this.m);
  final AssistantMessage m;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final rating = m.rating;
    Widget thumb(AssistantRatingRatingEnum value, IconData on, IconData off, String tip, bool selected) => IconButton(
          tooltip: tip,
          visualDensity: VisualDensity.compact,
          onPressed: () => rateAnswer(context, ref, m, value, selected),
          icon: Icon(selected ? on : off, size: 18, color: selected ? c.primary : c.ink3),
        );
    return Row(children: [
      if (m.durationMs != null) Text(l.massistantTook('${(m.durationMs! / 1000).round()}'), style: TextStyle(fontSize: 12.5, color: c.ink3)),
      const Spacer(),
      thumb(AssistantRatingRatingEnum.number1, Icons.thumb_up_alt, Icons.thumb_up_alt_outlined, l.massistantHelpful,
          rating == AssistantMessageRatingEnum.number1),
      thumb(AssistantRatingRatingEnum.numberNegative1, Icons.thumb_down_alt, Icons.thumb_down_alt_outlined, l.massistantNotHelpful,
          rating == AssistantMessageRatingEnum.numberNegative1),
    ]);
  }
}

/// Rates an answer: tapping the current rating takes it back; otherwise a
/// sheet asks for an optional comment and whether to keep the question's
/// data for prompt tests.
Future<void> rateAnswer(BuildContext context, WidgetRef ref, AssistantMessage m, AssistantRatingRatingEnum value, bool selected) async {
  final l = AppLocalizations.of(context);
  final api = ref.read(apiProvider)!.getAssistantApi();
  AssistantRating? rating;
  if (selected) {
    rating = AssistantRating(rating: AssistantRatingRatingEnum.number0);
  } else {
    rating = await showModalBottomSheet<AssistantRating>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _RateSheet(value: value),
    );
  }
  if (rating == null) return;
  try {
    await api.rateAssistantAnswer(messageId: m.id, assistantRating: rating);
    ref.invalidate(assistantConversationProvider);
    if (context.mounted && !selected) showSnack(context, l.massistantRated);
  } catch (e) {
    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
  }
}

class _RateSheet extends StatefulWidget {
  const _RateSheet({required this.value});
  final AssistantRatingRatingEnum value;

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  final _comment = TextEditingController();
  bool _share = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final up = widget.value == AssistantRatingRatingEnum.number1;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(up ? Icons.thumb_up_alt : Icons.thumb_down_alt, color: c.primary),
          const SizedBox(width: 10),
          Text(l.massistantRateTitle, style: Theme.of(context).textTheme.titleLarge),
        ]),
        const SizedBox(height: 14),
        TextField(
          controller: _comment,
          minLines: 2,
          maxLines: 5,
          maxLength: _maxQuestion,
          decoration: InputDecoration(hintText: l.massistantRateComment, border: const OutlineInputBorder()),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _share,
          onChanged: (v) => setState(() => _share = v),
          title: Text(l.massistantRateShare, style: TextStyle(fontSize: 14.5, color: c.ink)),
        ),
        Text(l.massistantRateNote, style: TextStyle(fontSize: 13, color: c.ink3)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(
              context,
              AssistantRating(rating: widget.value, comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(), share: _share),
            ),
            child: Text(l.massistantRateSend),
          ),
        ),
      ]),
    );
  }
}

/// The question field and the send button.
class _InputBar extends StatefulWidget {
  const _InputBar({required this.controller, required this.sending, required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final n = widget.controller.text.trim().length;
    final can = n > 0 && n <= _maxQuestion && !widget.sending;
    return Container(
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.line))),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: l.massistantPlaceholder,
                filled: true,
                fillColor: c.field,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filled(
            tooltip: l.massistantSend,
            onPressed: can ? widget.onSend : null,
            icon: widget.sending
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.onPrimary))
                : const Icon(Icons.arrow_upward_rounded),
          ),
        ]),
        if (n > _maxQuestion - 100)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(l.massistantCount('$n'), style: TextStyle(fontSize: 12, color: n > _maxQuestion ? c.badInk : c.ink3)),
          ),
      ]),
    );
  }
}
