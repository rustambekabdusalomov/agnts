import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../admin/admin_widgets.dart' show confirmAction;
import '../ci/ci_screen.dart' show ciAgo;
import 'kinds.dart' show ReportMarkdown;

/// A pull request's conversation on the git host, by repository id and
/// number. The live stream refreshes it on pr_comment events.
final pullThreadsProvider = FutureProvider.family<List<PullThread>, (int, int)>((ref, k) async {
  return (await requireApi(ref).getPullsApi().listPullThreads(id: k.$1, number: k.$2)).data ?? const [];
});

/// The pull requests whose conversation a ticket shows: the one a review
/// reviews, or the open ones agnts opened.
List<({int repoId, int number, String url, String? repoName})> ticketPulls(Ticket t) {
  if (t.kind == TicketKind.review) {
    final p = t.pull;
    return t.repoId != null && p != null ? [(repoId: t.repoId!, number: p.number, url: p.url, repoName: null)] : const [];
  }
  final rs = (t.repos ?? const <TicketRepoState>[]).where((r) => r.prNumber != null && r.closedAt == null).toList();
  if (rs.isEmpty && t.repoId != null && t.prNumber != null) return [(repoId: t.repoId!, number: t.prNumber!, url: t.prUrl, repoName: null)];
  return [for (final r in rs) (repoId: r.repoId, number: r.prNumber!, url: r.prUrl, repoName: rs.length > 1 ? r.repoName : null)];
}

String _host(String url) => Uri.tryParse(url)?.host.contains('gitlab') == true ? 'GitLab' : 'GitHub';

/// Mirrors the server: someone else's unresolved thread that agnts did not
/// answer last.
bool _fromReviewer(PullThread th) {
  if (th.comments.isEmpty || th.resolved) return false;
  final first = th.comments.first;
  if (first.mine || first.system || first.agnts || first.author.toLowerCase().endsWith('[bot]')) return false;
  if (th.kind == PullThreadKindEnum.review && th.reviewState == 'APPROVED' && first.body.trim().isEmpty) return false;
  return !th.comments.last.agnts;
}

/// The conversation fold on the ticket screen: read, comment, reply, edit,
/// delete and resolve; on agnts's own pull request, send the reviewers'
/// threads back to coding.
class PullCommentsFold extends ConsumerStatefulWidget {
  const PullCommentsFold({super.key, required this.ticket, required this.repoId, required this.number, required this.url, this.repoName});
  final Ticket ticket;
  final int repoId;
  final int number;
  final String url;
  final String? repoName;

  @override
  ConsumerState<PullCommentsFold> createState() => _PullCommentsFoldState();
}

class _PullCommentsFoldState extends ConsumerState<PullCommentsFold> {
  bool _busy = false;
  bool _resolved = false;

  PullsApi get _api => ref.read(apiProvider)!.getPullsApi();
  (int, int) get _k => (widget.repoId, widget.number);
  bool get _own => widget.ticket.kind != TicketKind.review;

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(pullThreadsProvider(_k));
      if (done != null && mounted) showSnack(context, done);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _compose({String initial = '', required String action}) {
    final l = AppLocalizations.of(context);
    final text = TextEditingController(text: initial);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: text,
            autofocus: true,
            minLines: 4,
            maxLines: 10,
            maxLength: 60000,
            decoration: InputDecoration(hintText: l.pullsPlaceholder),
          ),
          Text(l.pullsPostsAsToken(_host(widget.url)), style: TextStyle(fontSize: 12.5, color: Agnts.of(ctx).ink3)),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              final b = text.text.trim();
              if (b.isNotEmpty) Navigator.pop(ctx, b);
            },
            child: Text(action),
          ),
        ]),
      ),
    );
  }

  Future<void> _comment() async {
    final l = AppLocalizations.of(context);
    final body = await _compose(action: l.pullsComment);
    if (body == null) return;
    await _run(() => _api.addPullComment(id: widget.repoId, number: widget.number, newPullComment: NewPullComment(body: body)));
  }

  Future<void> _reply(PullThread th) async {
    final l = AppLocalizations.of(context);
    final body = await _compose(action: l.pullsReply);
    if (body == null) return;
    await _run(() => _api.replyPullThread(
          id: widget.repoId,
          number: widget.number,
          replyPullThreadRequest: ReplyPullThreadRequest(threadId: th.id, body: body),
        ));
  }

  Future<void> _edit(PullComment c) async {
    final l = AppLocalizations.of(context);
    final body = await _compose(initial: c.body, action: l.pullsSave);
    if (body == null) return;
    await _run(() => _api.editPullComment(
          id: widget.repoId,
          number: widget.number,
          editPullCommentRequest: EditPullCommentRequest(commentId: c.id, body: body),
        ));
  }

  Future<void> _delete(PullComment c) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.pullsDeleteTitle, body: l.pullsDeleteConfirm, action: l.pullsDelete, danger: true)) return;
    await _run(() => _api.deletePullComment(id: widget.repoId, number: widget.number, commentId: c.id), done: l.pullsDeleted);
  }

  Future<void> _resolve(PullThread th) => _run(() => _api.resolvePullThread(
        id: widget.repoId,
        number: widget.number,
        resolvePullThreadRequest: ResolvePullThreadRequest(threadId: th.id, resolved: !th.resolved),
      ));

  Future<void> _address(int n) async {
    final l = AppLocalizations.of(context);
    final label = l.pullsAddressBtn(n);
    if (!await confirmAction(context, title: label, body: l.pullsAddressConfirm(widget.ticket.key, n), action: label)) return;
    await _run(() async {
      await ref.read(apiProvider)!.getTicketsApi().addressPullComments(key: widget.ticket.key);
      ref.invalidate(ticketProvider(widget.ticket.key));
      ref.invalidate(ticketsProvider);
    }, done: l.pullsAddressed(n));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final canEdit = ref.watch(canEditProvider);
    final threads = ref.watch(pullThreadsProvider(_k));
    final all = threads.value ?? const <PullThread>[];
    final shown = all.where((th) => !th.comments.every((x) => x.system) && (_resolved || !th.resolved)).toList();
    final resolvedN = all.where((th) => th.resolved).length;
    final fresh = _own ? all.where((th) => _fromReviewer(th) && th.sent != true).length : 0;
    final t = widget.ticket;
    final canAddress = _own && canEdit && fresh > 0 &&
        (t.state == TicketState.waitingForReview || (t.state == TicketState.done && t.mergedAt == null));

    return Fold(
      // Opens by itself once new reviewer comments arrive.
      key: ValueKey('pull-${widget.repoId}-${widget.number}-${fresh > 0}'),
      title: l.pullsTicketTitle('${widget.number}', _host(widget.url)),
      hint: threads.hasValue ? '${all.length}' : null,
      initiallyOpen: fresh > 0,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          widget.repoName != null ? l.pullsTicketSubIn(widget.repoName!) : (_own ? l.pullsTicketSubOwn : l.pullsTicketSubReview),
          style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3),
        ),
        if (canAddress) ...[
          const SizedBox(height: 10),
          FilledButton(onPressed: _busy ? null : () => _address(fresh), child: Text(l.pullsAddressBtn(fresh))),
        ] else if (_own && fresh > 0) ...[
          const SizedBox(height: 8),
          Text(l.pullsAddressLater(fresh), style: TextStyle(fontSize: 13, color: c.ink3)),
        ],
        const SizedBox(height: 10),
        if (threads.isLoading && !threads.hasValue)
          Text(l.commonLoading, style: TextStyle(color: c.ink3))
        else if (threads.hasError && !threads.hasValue)
          Text(errorMessage(threads.error!, l.commonError), style: TextStyle(color: c.badInk))
        else if (shown.isEmpty)
          Text(l.pullsNoComments, style: TextStyle(color: c.ink3)),
        for (final th in shown) _thread(context, th, canEdit),
        if (resolvedN > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _resolved = !_resolved),
              child: Text(_resolved ? l.pullsResolved : l.pullsShowResolved('$resolvedN')),
            ),
          ),
        if (canEdit) ...[
          const SizedBox(height: 6),
          OutlinedButton(onPressed: _busy ? null : _comment, child: Text(l.pullsAddComment)),
        ],
      ]),
    );
  }

  Widget _thread(BuildContext context, PullThread th, bool canEdit) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final line = th.line ?? th.oldLine;
    final verdict = th.kind == PullThreadKindEnum.review ? th.reviewState : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (th.kind == PullThreadKindEnum.inline)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('${th.path ?? ''}${line != null ? ':$line' : ''}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2)),
              if (th.outdated) ToneBadge(l.pullsOutdated, Tone.gray, small: true),
              if (th.resolved) ToneBadge(l.pullsResolved, Tone.ok, small: true),
              if (th.sent == true) ToneBadge(th.replied == true ? l.pullsAnswered : l.pullsSent, Tone.info, small: true),
            ]),
          ),
        for (final (i, cm) in th.comments.indexed)
          if (!cm.system)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 6, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text(cm.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  if (i == 0 && verdict != null) ToneBadge(_verdict(l, verdict), verdict == 'CHANGES_REQUESTED' ? Tone.bad : verdict == 'APPROVED' ? Tone.ok : Tone.gray, small: true),
                  if (cm.agnts) const ToneBadge('agnts', Tone.info, small: true),
                  Text(ciAgo(l, cm.createdAt), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                  if (cm.updatedAt.difference(cm.createdAt).inSeconds > 1) Text('· ${l.pullsEdited}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
                ]),
                if (cm.body.trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: ReportMarkdown(cm.body)),
                if (canEdit && cm.mine)
                  Wrap(children: [
                    TextButton(onPressed: _busy ? null : () => _edit(cm), child: Text(l.pullsEdit)),
                    if (!cm.id.startsWith('rv:'))
                      TextButton(
                        onPressed: _busy ? null : () => _delete(cm),
                        child: Text(l.pullsDelete, style: TextStyle(color: c.badInk)),
                      ),
                  ]),
              ]),
            ),
        if (canEdit)
          Wrap(children: [
            TextButton(onPressed: _busy ? null : () => _reply(th), child: Text(l.pullsReply)),
            if (th.resolvable)
              TextButton(onPressed: _busy ? null : () => _resolve(th), child: Text(th.resolved ? l.pullsUnresolve : l.pullsResolve)),
          ]),
      ]),
    );
  }
}

String _verdict(AppLocalizations l, String v) => switch (v) {
      'APPROVED' => l.pullsVerdict_APPROVED,
      'CHANGES_REQUESTED' => l.pullsVerdict_CHANGES_REQUESTED,
      'DISMISSED' => l.pullsVerdict_DISMISSED,
      _ => l.pullsVerdict_COMMENTED,
    };
