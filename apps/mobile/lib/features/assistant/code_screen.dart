import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../core/live.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/attachments.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../repos/manage_widgets.dart' show confirmAction;
import '../tasks/repo_pick.dart';
import '../tickets/kinds.dart' show ReportMarkdown;
import 'assistant_data.dart';
import 'code_data.dart';
import 'conversations_sheet.dart';

const _maxMessage = 4000;

/// The chat's Code mode. A conversation drives tickets: the first message
/// (with the repositories picked, or a ticket to work on) starts one, and
/// each next message goes to it by its state: answers, requested changes, a
/// retry note, or a wait until the running stage ends. The work shows as
/// the ticket's own events, live; Approve and Reject are on its result.
class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({super.key, this.conversationId, this.initialText, this.initialRepos = const [], this.initialTicket});
  final int? conversationId;

  /// A new conversation's request, repositories and ticket, prefilled.
  final String? initialText;
  final List<int> initialRepos;
  final String? initialTicket;

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  final _text = TextEditingController();
  final _ticketKey = TextEditingController();
  late final _files = AttachmentsController()..addListener(_changed);
  int? _id;
  bool _sending = false;
  bool _attach = false;
  var _pick = const RepoPick();
  var _kind = TicketKindChoice.auto;
  bool _quick = false;
  final _live = <Event>[];
  StreamSubscription<Map<String, dynamic>>? _sub;

  @override
  void initState() {
    super.initState();
    _id = widget.conversationId;
    _text.text = (widget.initialText ?? '').characters.take(_maxMessage).toString();
    // The composer reads the key: with one, the message picks that ticket up.
    _ticketKey.text = widget.initialTicket ?? '';
    _ticketKey.addListener(_changed);
    if (widget.initialRepos.isNotEmpty) _pick = RepoPick(ids: widget.initialRepos);
    _sub = ref.read(liveProvider).events.listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _text.dispose();
    _ticketKey.dispose();
    _files.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  Set<String> _keys() {
    final c = _id == null ? null : ref.read(codeTimelineProvider(_id!)).value?.conversation;
    return {for (final t in c?.tickets ?? const <CodeTicket>[]) t.key};
  }

  /// The conversation's tickets' events, as they happen.
  void _onEvent(Map<String, dynamic> raw) {
    if (_id == null || !mounted) return;
    final key = raw['ticketKey'] as String? ?? '';
    if (!_keys().contains(key)) return;
    Event e;
    try {
      e = Event.fromJson(raw);
    } catch (_) {
      return;
    }
    if (codeTimelineTypes.contains(e.type) && e.id > 0) setState(() => _live.add(e));
    if (e.type == 'state_changed' || e.type == 'review_ready') ref.invalidate(codeTimelineProvider(_id!));
  }

  Future<void> _send({List<CodeSendAnswersInner>? answers}) async {
    final l = AppLocalizations.of(context);
    final text = _text.text.trim();
    if (_sending || _files.uploading || text.length > _maxMessage) return;
    if (answers == null && text.isEmpty && _files.ids.isEmpty) return;
    final key = _ticketKey.text.trim();
    // None picked: the server works in the repositories the message names.
    if (_id == null && _pick.isEmpty && key.isEmpty && text.isEmpty) return showSnack(context, l.codechatReposNone);
    setState(() => _sending = true);
    final api = ref.read(apiProvider)!.getAssistantApi();
    try {
      if (_id == null) {
        final p = _pick.payload;
        final res = await api.startCodeConversation(
          codeStart: CodeStart(
            text: text.isEmpty ? null : text,
            attachments: _files.ids.isEmpty ? null : _files.ids,
            repos: key.isEmpty ? RepoChoice(repoId: p.repoId, repoIds: p.repoIds, groupId: p.groupId) : null,
            kind: _kind,
            quick: _quick,
            ticketKey: key.isEmpty ? null : key,
          ),
        );
        setState(() => _id = res.data!.id);
      } else {
        await api.sendCodeMessage(
          conversationId: _id!,
          codeSend: answers != null
              ? CodeSend(answers: answers)
              : CodeSend(text: text.isEmpty ? null : text, attachments: _files.ids.isEmpty ? null : _files.ids),
        );
        ref.invalidate(codeTimelineProvider(_id!));
      }
      if (answers == null) {
        _text.clear();
        _files.clear();
        _attach = false;
      }
      ref.invalidate(assistantConversationsProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendNow(String key) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l.codechatSendNowTitle(key),
      message: l.codechatSendNowText,
      confirmLabel: l.codechatSendNow,
      danger: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(apiProvider)!.getAssistantApi().sendCodeQueuedNow(conversationId: _id!);
      ref.invalidate(codeTimelineProvider(_id!));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }

  Future<void> _history() async {
    final picked = await showConversationsSheet(context, current: _id);
    if (!mounted || picked == null) return;
    if (picked == 0) return setState(() => _id = null);
    final mode = ref.read(assistantConversationsProvider).value?.where((c) => c.id == picked).firstOrNull?.mode;
    if (mode == ChatMode.chat) {
      context.pushReplacement('/assistant/$picked');
    } else {
      setState(() {
        _id = picked;
        _live.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final canEdit = ref.watch(canEditProvider);
    final tl = _id == null ? null : ref.watch(codeTimelineProvider(_id!));
    final conv = tl?.value?.conversation;
    final cur = currentTicket(conv);
    final detail = cur == null ? null : ref.watch(ticketProvider(cur.key)).value;
    final tk = detail?.ticket.key == cur?.key ? detail?.ticket : null;
    final state = tk?.state ?? cur?.state;

    // Events the next fetch already has are dropped from the live list.
    final base = tl?.value?.items ?? const <TimelineItem>[];
    final items = [
      ...base,
      ...codeLiveItems(base, _live, {for (final t in conv?.tickets ?? const <CodeTicket>[]) t.key}),
    ];
    final blocks = codeBlocks(items);

    Widget body;
    if (!canEdit) {
      body = EmptyState(title: l.codechatViewersOnly);
    } else if (_id == null) {
      body = _Setup(
        pick: _pick,
        kind: _kind,
        quick: _quick,
        ticketKey: _ticketKey,
        onPick: (p) => setState(() => _pick = p),
        onKind: (k) => setState(() => _kind = k),
        onQuick: (q) => setState(() => _quick = q),
      );
    } else if (tl!.hasError && conv == null) {
      body = EmptyState(title: l.mobileOffline);
    } else if (conv == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final cards = <Widget>[
        for (final a in tl.value!.approvals.where((a) => a.status == CodeApprovalStatusEnum.pending)) _ApprovalCard(a, key: ValueKey(a.id)),
        if (cur != null && codeRunning(state))
          _Working(
            events: [
              for (final it in items)
                if (it.event?.ticketKey == cur.key) it.event!,
            ],
          ),
        if (cur != null && codeRunning(state) && codeQueued(conv).isNotEmpty)
          _Note(
            tone: Tone.warn,
            title: l.codechatQueuedTitle(codeQueued(conv).length),
            action: state == TicketState.pushing ? null : TextButton(onPressed: () => _sendNow(cur.key), child: Text(l.codechatSendNow)),
          ),
        if (cur != null && state == TicketState.waitingForReview && detail != null) _Result(detail, conversationId: _id!),
        if (cur != null && state == TicketState.waitingForAnswers && detail != null)
          _Questions(
            detail,
            busy: _sending,
            onSend: (a) => _send(answers: a),
          ),
        if (cur != null && (state == TicketState.failed || state == TicketState.rateLimited))
          _Note(
            tone: Tone.bad,
            title: l.codechatStoppedTitle(cur.key),
            text: [if (tk?.stopReason != null) tk!.stopReason!, l.codechatStoppedHint].join('\n\n'),
          ),
        if (cur != null && state == TicketState.done) _Note(tone: Tone.ok, title: l.codechatDoneTitle(cur.key), text: l.codechatDoneHint),
        if (cur != null && state == TicketState.rejected)
          _Note(tone: Tone.gray, title: l.codechatRejectedTitle(cur.key), text: l.codechatRejectedHint),
        if (cur == null && (conv.tickets?.isNotEmpty ?? false)) _Note(tone: Tone.gray, title: l.codechatMovedHint(conv.tickets!.last.key)),
      ];
      // Newest at the bottom, kept in view as the work goes on.
      final rows = <Widget>[for (final b in blocks) _BlockView(b), ...cards];
      body = Column(
        children: [
          _Header(conv: conv, cur: cur, state: state),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: rows.length,
              itemBuilder: (_, i) => rows[rows.length - 1 - i],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: conv?.title ?? l.codechatTitle,
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        actions: [
          IconButton(
            tooltip: l.codechatModeChat,
            onPressed: () => context.pushReplacement('/assistant'),
            icon: HIcon('assistant', size: 22, color: c.primary),
          ),
          IconButton(
            tooltip: l.massistantHistory,
            onPressed: _history,
            icon: HIcon('logs', size: 22, color: c.primary),
          ),
          if (_id != null)
            IconButton(
              tooltip: l.codechatNewConversation,
              onPressed: () => setState(() {
                _id = null;
                _live.clear();
              }),
              icon: HIcon('plus', size: 22, color: c.primary),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: body),
            if (canEdit)
              _InputBar(
                controller: _text,
                files: _files,
                attach: _attach,
                onAttach: () => setState(() => _attach = !_attach),
                sending: _sending,
                enabled: state != TicketState.pushing,
                hint: codePlaceholder(l, conv == null ? null : state),
                onSend: () => _send(),
                repos: ref.watch(reposProvider).value ?? const <Repository>[],
                // A message that starts a ticket works in its @mentions; a
                // first one with none picked, in the names it uses.
                startsTicket: _id == null ? _ticketKey.text.trim().isEmpty : cur == null || state == TicketState.done,
                plain: _id == null && _pick.isEmpty && _ticketKey.text.trim().isEmpty,
              ),
          ],
        ),
      ),
    );
  }
}

/// A new conversation: the repositories (or a ticket to pick up), the kind
/// and whether tickets skip their checks.
class _Setup extends ConsumerWidget {
  const _Setup({
    required this.pick,
    required this.kind,
    required this.quick,
    required this.ticketKey,
    required this.onPick,
    required this.onKind,
    required this.onQuick,
  });
  final RepoPick pick;
  final TicketKindChoice kind;
  final bool quick;
  final TextEditingController ticketKey;
  final ValueChanged<RepoPick> onPick;
  final ValueChanged<TicketKindChoice> onKind;
  final ValueChanged<bool> onQuick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final repos = ref.watch(reposProvider).value ?? const <Repository>[];
    final groups = (ref.watch(repoGroupsProvider).value ?? const <RepoGroup>[]).where((g) => RepoPick.members(g).isNotEmpty).toList();
    final sub = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3);
    final kinds = {
      TicketKindChoice.auto: l.kindAuto,
      TicketKindChoice.code: l.kindCode,
      TicketKindChoice.test: l.kindTest,
      TicketKindChoice.plan: l.kindPlan,
      TicketKindChoice.analysis: l.kindAnalysis,
      TicketKindChoice.bug: l.kindBug,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      children: [
        Center(child: HIcon('code', size: 36, color: c.primary)),
        EmptyState(title: l.codechatEmptyTitle, text: l.codechatEmptyText),
        Text(l.codechatRepos, style: sub),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in groups)
              FilterChipH(
                label: g.name,
                count: RepoPick.members(g).length,
                selected: pick.wholeGroup?.id == g.id,
                onTap: () => onPick(pick.wholeGroup?.id == g.id ? const RepoPick() : pick.pickGroup(g)),
              ),
            for (final r in repos.where((r) => r.archivedAt == null))
              FilterChipH(label: r.name, selected: pick.contains(r.id), onTap: () => onPick(pick.toggle(r.id))),
          ],
        ),
        const SizedBox(height: 16),
        Text(l.codechatKind, style: sub),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final e in kinds.entries) FilterChipH(label: e.value, selected: kind == e.key, onTap: () => onKind(e.key))],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: quick,
          onChanged: onQuick,
          title: Text(l.codechatQuick, style: TextStyle(fontSize: 14.5, color: c.ink)),
          subtitle: Text(l.codechatQuickHint, style: TextStyle(fontSize: 13, color: c.ink3)),
        ),
        const SizedBox(height: 8),
        Text(l.codechatTicketPick, style: sub),
        const SizedBox(height: 6),
        TextField(
          controller: ticketKey,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(hintText: l.codechatTicketPlaceholder, isDense: true, border: const OutlineInputBorder()),
        ),
      ],
    );
  }
}

/// The current ticket, its state and the conversation's repositories.
class _Header extends StatelessWidget {
  const _Header({required this.conv, required this.cur, required this.state});
  final AssistantConversation conv;
  final CodeTicket? cur;
  final TicketState? state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = cur;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.line)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (t != null) ...[
            InkWell(
              onTap: () => context.push('/tickets/${t.key}'),
              child: Text(
                t.key,
                style: TextStyle(fontFamily: AgntsFonts.mono, fontWeight: FontWeight.w700, color: c.primary),
              ),
            ),
            StateBadge(state ?? t.state, kind: t.kind),
            Text(t.repos.join(', '), style: TextStyle(fontSize: 13, color: c.ink3)),
          ],
          if (conv.quick ?? false) ToneBadge(l.codechatQuick, Tone.gray, small: true),
        ],
      ),
    );
  }
}

/// One block of the timeline.
class _BlockView extends StatelessWidget {
  const _BlockView(this.b);
  final CodeBlock b;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    switch (b) {
      case CodeMessageBlock(:final message):
        final routed = routedLabel(l, message);
        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(18)),
                  child: SelectableText(message.text, style: TextStyle(fontSize: 15, height: 1.4, color: c.primaryInk)),
                ),
                if (routed.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      routed,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: message.routed == CodeRouted.failed
                            ? c.badInk
                            : message.routed == CodeRouted.queued
                            ? c.warnInk
                            : c.ink3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      case CodeRunBlock(:final parts):
        // A Material, not a coloured box: the folded steps draw their ink on it.
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, right: 24),
            child: Material(
              color: c.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: c.line),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final p in parts)
                      if (p is Event) ReportMarkdown(p.message) else _Steps(p as List<Event>),
                  ],
                ),
              ),
            ),
          ),
        );
      case CodeLineBlock(:final event):
        final to = event.data['to'];
        final state = to is String ? TicketState.values.where((s) => s.value == to).firstOrNull : null;
        final color = event.level == EventLevelEnum.error ? c.badInk : (event.level == EventLevelEnum.warn ? c.warnInk : c.ink3);
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: event.type == 'state_changed' && state != null
                ? Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        event.ticketKey,
                        style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3),
                      ),
                      StateBadge(state),
                    ],
                  )
                : Text(
                    event.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: color),
                  ),
          ),
        );
    }
  }
}

/// Tool calls between two texts, folded: "4 steps · Edit · timer.go".
class _Steps extends StatelessWidget {
  const _Steps(this.events);
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final style = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 6),
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(
          '${l.codechatSteps(events.length)} · ${events.last.message}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final e in events)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(e.message, style: style),
            ),
        ],
      ),
    );
  }
}

/// While a stage runs: a spinner and, on Muse, what the run has spent.
class _Working extends StatelessWidget {
  const _Working({required this.events});
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    double? spent;
    for (final e in events.reversed) {
      final total = e.type == 'budget' ? e.data['total_usd'] : null;
      if (total is num) {
        spent = total.toDouble();
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Text(
            l.codechatWorking,
            style: TextStyle(fontWeight: FontWeight.w700, color: c.ink2),
          ),
          if (spent != null) ...[
            const SizedBox(width: 10),
            Text(
              '\$${spent.toStringAsFixed(spent < 1 ? 3 : 2)}',
              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

/// A short card: why it stopped, that it is done, what waits.
class _Note extends StatelessWidget {
  const _Note({required this.tone, required this.title, this.text, this.action});
  final Tone tone;
  final String title;
  final String? text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final ink = switch (tone) {
      Tone.bad => c.badInk,
      Tone.warn => c.warnInk,
      Tone.ok => c.okInk,
      _ => c.ink,
    };
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tone == Tone.warn ? c.warnSoft : c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: ink),
          ),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text!, style: TextStyle(fontSize: 13.5, color: c.ink2)),
            ),
          if (action != null) Align(alignment: Alignment.centerRight, child: action),
        ],
      ),
    );
  }
}

/// The work waiting for review: what changed, the checks, and Approve or
/// Reject (asked once more). The diff is on the ticket's screen.
class _Result extends ConsumerStatefulWidget {
  const _Result(this.d, {required this.conversationId});
  final TicketDetail d;
  final int conversationId;

  @override
  ConsumerState<_Result> createState() => _ResultState();
}

class _ResultState extends ConsumerState<_Result> {
  bool _busy = false;

  bool get _report => const [TicketKind.plan, TicketKind.analysis, TicketKind.bug].contains(widget.d.ticket.kind);

  Future<void> _decide(bool approve) async {
    final l = AppLocalizations.of(context);
    final t = widget.d.ticket;
    final message = !approve
        ? l.codechatRejectText
        : _report
        ? l.codechatApproveReport
        : t.afterApprove == TicketAfterApproveEnum.main
        ? l.codechatApproveMain
        : l.codechatApprovePr(t.branch);
    final ok = await confirmAction(
      context,
      title: approve ? l.codechatApproveTitle(t.key) : l.codechatRejectTitle(t.key),
      message: message,
      confirmLabel: approve ? l.codechatApprove : l.codechatReject,
      danger: !approve,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final api = ref.read(apiProvider)!.getTicketsApi();
    try {
      if (approve) {
        await api.approveTicket(key: t.key, approveTicketRequest: _report ? ApproveTicketRequest(postReport: false) : null);
      } else {
        await api.rejectTicket(key: t.key, rejectTicketRequest: RejectTicketRequest());
      }
      refreshAfterDecision(ref.invalidate, t.key);
      ref.invalidate(codeTimelineProvider(widget.conversationId));
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
    final t = widget.d.ticket;
    final r = widget.d.result;
    final files = r?.files ?? const <FileChange>[];
    final add = files.fold<int>(0, (n, f) => n + f.add);
    final del = files.fold<int>(0, (n, f) => n + f.del);
    final checks = r?.checks ?? const <CheckStep>[];
    final failed = checks.where((x) => x.exitCode != 0).length;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _report ? l.codechatReportTitle(t.key) : l.codechatResultTitle(t.key),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          if (_report && r?.report != null)
            ReportMarkdown(r!.report!)
          else if (r != null && r.summary.isNotEmpty)
            ReportMarkdown(r.summary),
          if (!_report)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${l.codechatFilesChanged(files.length)} '),
                        TextSpan(
                          text: '+$add',
                          style: TextStyle(color: c.okInk, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: ' −$del',
                          style: TextStyle(color: c.badInk, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 14, color: c.ink2),
                  ),
                  if (t.skipChecks)
                    ToneBadge(l.codechatChecksSkipped, Tone.gray, small: true)
                  else if (checks.isNotEmpty)
                    failed > 0
                        ? ToneBadge(l.codechatChecksFailed('$failed', '${checks.length}'), Tone.bad, small: true)
                        : ToneBadge(l.codechatChecksPassed, Tone.ok, small: true),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(onPressed: _busy ? null : () => _decide(true), child: Text(l.codechatApprove)),
              OutlinedButton(onPressed: _busy ? null : () => _decide(false), child: Text(l.codechatReject)),
              TextButton(
                onPressed: () => context.push('/tickets/${t.key}'),
                child: Text(files.isEmpty ? l.codechatOpenTicket : l.codechatViewDiff),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The ticket's questions, one field each; options fill the field.
class _Questions extends StatefulWidget {
  const _Questions(this.d, {required this.busy, required this.onSend});
  final TicketDetail d;
  final bool busy;
  final void Function(List<CodeSendAnswersInner>) onSend;

  @override
  State<_Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<_Questions> {
  final _answers = <int, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _answers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _field(int id) => _answers.putIfAbsent(id, () => TextEditingController()..addListener(() => setState(() {})));

  void _pick(Question q, String o) {
    final f = _field(q.id);
    if (!q.multiple) {
      f.text = o;
      return;
    }
    final have = f.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    have.contains(o) ? have.remove(o) : have.add(o);
    f.text = have.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final open = widget.d.questions.where((q) => q.answer == null).toList();
    final ready = open.isNotEmpty && open.every((q) => _field(q.id).text.trim().isNotEmpty);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.warn),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.codechatQuestionsTitle(widget.d.ticket.key), style: const TextStyle(fontWeight: FontWeight.w700)),
          for (final q in open) ...[
            const SizedBox(height: 10),
            Text(
              q.text,
              style: TextStyle(fontWeight: FontWeight.w600, color: c.ink),
            ),
            if (q.options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final o in q.options)
                      FilterChipH(label: o, selected: _field(q.id).text.split('\n').contains(o), onTap: () => setState(() => _pick(q, o))),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            TextField(
              controller: _field(q.id),
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: !ready || widget.busy
                  ? null
                  : () => widget.onSend([for (final q in open) CodeSendAnswersInner(questionId: q.id, answer: _field(q.id).text.trim())]),
              child: Text(l.codechatAnswersSend),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tool call the agent waits on: Allow or Deny, before its time runs out.
class _ApprovalCard extends ConsumerStatefulWidget {
  const _ApprovalCard(this.a, {super.key});
  final CodeApproval a;

  @override
  ConsumerState<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends ConsumerState<_ApprovalCard> {
  Timer? _tick;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _decide(bool allow) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(apiProvider)!
          .getAssistantApi()
          .decideCodeApproval(
            approvalId: widget.a.id,
            decideCodeApprovalRequest: DecideCodeApprovalRequest(allow: allow),
          );
      ref.invalidate(codeTimelineProvider(widget.a.conversationId));
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
    final left = a.expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 9999);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: c.warnSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.warn),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.codechatApprovalTitle,
            style: TextStyle(fontWeight: FontWeight.w700, color: c.warnInk),
          ),
          const SizedBox(height: 6),
          SelectableText(
            a.command ?? a.path ?? a.tool,
            style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink),
          ),
          const SizedBox(height: 4),
          Text(l.codechatApprovalReason(a.reason), style: TextStyle(fontSize: 13, color: c.ink2)),
          Row(
            children: [
              Text(
                left == 0 ? l.codechatApprovalExpired : l.codechatApprovalLeft('$left'),
                style: TextStyle(fontSize: 12.5, color: c.ink3),
              ),
              const Spacer(),
              TextButton(onPressed: _busy || left == 0 ? null : () => _decide(false), child: Text(l.codechatApprovalDeny)),
              FilledButton(onPressed: _busy || left == 0 ? null : () => _decide(true), child: Text(l.codechatApprovalAllow)),
            ],
          ),
        ],
      ),
    );
  }
}

/// The message field, files to attach and the send button.
class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.controller,
    required this.files,
    required this.attach,
    required this.onAttach,
    required this.sending,
    required this.enabled,
    required this.hint,
    required this.onSend,
    required this.repos,
    required this.startsTicket,
    required this.plain,
  });
  final TextEditingController controller;
  final AttachmentsController files;
  final bool attach;
  final VoidCallback onAttach;
  final bool sending;
  final bool enabled;
  final String hint;
  final VoidCallback onSend;
  final List<Repository> repos;
  final bool startsTicket;
  final bool plain;

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

  /// Writes @name for the mention being typed, as the person picked it.
  void _pickMention(({int start, String query}) m, Repository r) {
    final t = widget.controller;
    final out = insertMention(t.text, m.start, t.selection.baseOffset, r.name);
    t.value = TextEditingValue(
      text: out.text,
      selection: TextSelection.collapsed(offset: out.caret),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final text = widget.controller.text;
    final n = text.trim().length;
    final sel = widget.controller.selection;
    final mention = sel.isValid && sel.isCollapsed ? mentionAt(text, sel.baseOffset) : null;
    final options = mention == null ? const <Repository>[] : mentionOptions(mention.query, widget.repos);
    final named = widget.startsTicket ? mentionedRepos(text, widget.repos, plain: widget.plain) : const <int>[];
    final names = [for (final id in named) widget.repos.firstWhere((r) => r.id == id).name].join(', ');
    final can = widget.enabled && (n > 0 || widget.files.ids.isNotEmpty) && n <= _maxMessage && !widget.sending && !widget.files.uploading;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.line)),
      ),
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.attach)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: AttachmentPicker(controller: widget.files),
            ),
          if (options.isNotEmpty && widget.enabled)
            Semantics(
              label: l.codechatMentionLabel,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                child: Row(
                  children: [
                    for (final r in options)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChipH(label: '@${r.name}', selected: false, onTap: () => _pickMention(mention!, r)),
                      ),
                  ],
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: l.filesTitle,
                onPressed: widget.enabled ? widget.onAttach : null,
                icon: Icon(Icons.attach_file_rounded, color: widget.files.ids.isNotEmpty ? c.primary : c.ink3),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: widget.hint,
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
                tooltip: l.codechatSend,
                onPressed: can ? widget.onSend : null,
                icon: widget.sending
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.onPrimary))
                    : const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
          if (names.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 0),
              child: Row(
                children: [
                  HIcon('code', size: 14, color: c.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.codechatMentioned(names), style: TextStyle(fontSize: 12.5, color: c.ink2)),
                  ),
                ],
              ),
            ),
          if (n > _maxMessage - 200)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Text(
                l.codechatCount('$n'),
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12, color: n > _maxMessage ? c.badInk : c.ink3),
              ),
            ),
        ],
      ),
    );
  }
}

/// The person's Code conversation that works on a ticket, or null.
final ticketChatProvider = FutureProvider.family<int?, String>((ref, key) async {
  try {
    return (await requireApi(ref).getAssistantApi().getTicketChat(key: key)).data?.conversationId;
  } catch (_) {
    return null; // none (404), or the server has no Code mode
  }
});

/// A ticket's way into Code mode: its conversation, or a new one that
/// picks it up. Viewers, reviews and Swagger tests get none.
class TicketChatButton extends ConsumerWidget {
  const TicketChatButton(this.ticket, {super.key});
  final Ticket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    if (!ref.watch(canEditProvider) || ticket.kind == TicketKind.review || ticket.kind == TicketKind.swaggertest) {
      return const SizedBox.shrink();
    }
    final id = ref.watch(ticketChatProvider(ticket.key)).value;
    return IconButton(
      tooltip: id != null ? l.codechatTicketChat : l.codechatContinueInChat,
      onPressed: () => context.push(id != null ? '/assistant/code/$id' : '/assistant/code?ticket=${Uri.encodeQueryComponent(ticket.key)}'),
      icon: HIcon('code', size: 22, color: c.primary),
    );
  }
}
