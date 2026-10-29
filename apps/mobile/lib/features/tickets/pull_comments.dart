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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
          ],
        ),
      ),
    );
  }

  Future<void> _comment() async {
    final l = AppLocalizations.of(context);
    final body = await _compose(action: l.pullsComment);
    if (body == null) return;
    await _run(
      () => _api.addPullComment(
        id: widget.repoId,
        number: widget.number,
        newPullComment: NewPullComment(body: body),
      ),
    );
  }

  Future<void> _reply(PullThread th) async {
    final l = AppLocalizations.of(context);
    final body = await _compose(action: l.pullsReply);
    if (body == null) return;
    await _run(
      () => _api.replyPullThread(
        id: widget.repoId,
        number: widget.number,
        replyPullThreadRequest: ReplyPullThreadRequest(threadId: th.id, body: body),
      ),
    );
  }

  Future<void> _edit(PullComment c) async {
    final l = AppLocalizations.of(context);
    final body = await _compose(initial: c.body, action: l.pullsSave);
    if (body == null) return;
    await _run(
      () => _api.editPullComment(
        id: widget.repoId,
        number: widget.number,
        editPullCommentRequest: EditPullCommentRequest(commentId: c.id, body: body),
      ),
    );
  }

  Future<void> _delete(PullComment c) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.pullsDeleteTitle, body: l.pullsDeleteConfirm, action: l.pullsDelete, danger: true)) return;
    await _run(
      () => _api.deletePullComment(id: widget.repoId, number: widget.number, commentId: c.id),
      done: l.pullsDeleted,
    );
  }

  Future<void> _resolve(PullThread th) => _run(
    () => _api.resolvePullThread(
      id: widget.repoId,
      number: widget.number,
      resolvePullThreadRequest: ResolvePullThreadRequest(threadId: th.id, resolved: !th.resolved),
    ),
  );

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
    final canAddress =
        _own && canEdit && fresh > 0 && (t.state == TicketState.waitingForReview || (t.state == TicketState.done && t.mergedAt == null));

    return Fold(
      // Opens by itself once new reviewer comments arrive.
      key: ValueKey('pull-${widget.repoId}-${widget.number}-${fresh > 0}'),
      title: l.pullsTicketTitle('${widget.number}', _host(widget.url)),
      hint: threads.hasValue ? '${all.length}' : null,
      initiallyOpen: fresh > 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          if (canEdit) ...[const SizedBox(height: 6), OutlinedButton(onPressed: _busy ? null : _comment, child: Text(l.pullsAddComment))],
        ],
      ),
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
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (th.kind == PullThreadKindEnum.inline)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${th.path ?? ''}${line != null ? ':$line' : ''}',
                    style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                  ),
                  if (th.outdated) ToneBadge(l.pullsOutdated, Tone.gray, small: true),
                  if (th.resolved) ToneBadge(l.pullsResolved, Tone.ok, small: true),
                  if (th.sent == true) ToneBadge(th.replied == true ? l.pullsAnswered : l.pullsSent, Tone.info, small: true),
                ],
              ),
            ),
          for (final (i, cm) in th.comments.indexed)
            if (!cm.system)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(cm.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        if (i == 0 && verdict != null)
                          ToneBadge(
                            _verdict(l, verdict),
                            verdict == 'CHANGES_REQUESTED'
                                ? Tone.bad
                                : verdict == 'APPROVED'
                                ? Tone.ok
                                : Tone.gray,
                            small: true,
                          ),
                        if (cm.agnts) const ToneBadge('agnts', Tone.info, small: true),
                        Text(ciAgo(l, cm.createdAt), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                        if (cm.updatedAt.difference(cm.createdAt).inSeconds > 1)
                          Text('· ${l.pullsEdited}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
                      ],
                    ),
                    if (cm.body.trim().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: ReportMarkdown(cm.body)),
                    if (canEdit && cm.mine)
                      Wrap(
                        children: [
                          TextButton(onPressed: _busy ? null : () => _edit(cm), child: Text(l.pullsEdit)),
                          if (!cm.id.startsWith('rv:'))
                            TextButton(
                              onPressed: _busy ? null : () => _delete(cm),
                              child: Text(l.pullsDelete, style: TextStyle(color: c.badInk)),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
          if (canEdit)
            Wrap(
              children: [
                TextButton(onPressed: _busy ? null : () => _reply(th), child: Text(l.pullsReply)),
                if (th.resolvable)
                  TextButton(onPressed: _busy ? null : () => _resolve(th), child: Text(th.resolved ? l.pullsUnresolve : l.pullsResolve)),
              ],
            ),
        ],
      ),
    );
  }
}

String _verdict(AppLocalizations l, String v) => switch (v) {
  'APPROVED' => l.pullsVerdict_APPROVED,
  'CHANGES_REQUESTED' => l.pullsVerdict_CHANGES_REQUESTED,
  'DISMISSED' => l.pullsVerdict_DISMISSED,
  _ => l.pullsVerdict_COMMENTED,
};

/// The draft comments of a pull request review, by ticket key. The live
/// stream refreshes them when a review run ends or a review is published.
final reviewDraftsProvider = FutureProvider.family<List<ReviewDraft>, String>((ref, key) async {
  return (await requireApi(ref).getReviewsApi().listReviewDrafts(key: key)).data ?? const [];
});

/// agnts's review comments kept in agnts: accept, edit or dismiss each, add
/// your own, then publish the accepted ones on the git host as one review.
/// Drafts not accepted never leave agnts.
class ReviewDraftsFold extends ConsumerStatefulWidget {
  const ReviewDraftsFold({super.key, required this.ticket});
  final Ticket ticket;

  @override
  ConsumerState<ReviewDraftsFold> createState() => _ReviewDraftsFoldState();
}

class _ReviewDraftsFoldState extends ConsumerState<ReviewDraftsFold> {
  bool _busy = false;
  bool _closed = false;

  ReviewsApi get _api => ref.read(apiProvider)!.getReviewsApi();
  String get _key => widget.ticket.key;
  String get _host => _hostOf(widget.ticket.pull?.url ?? widget.ticket.prUrl);
  bool get _locked =>
      widget.ticket.state == TicketState.rejected ||
      (widget.ticket.pull?.state != null && widget.ticket.pull!.state != PullRequestStateEnum.open);

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(reviewDraftsProvider(_key));
      if (done != null && mounted) showSnack(context, done);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _set(ReviewDraft d, UpdateReviewDraftRequestStateEnum state, {String? reason}) => _run(
    () => _api.updateReviewDraft(
      key: _key,
      draftId: d.id,
      updateReviewDraftRequest: UpdateReviewDraftRequest(state: state, dismissReason: reason),
    ),
  );

  /// The text of a new or edited draft, from a sheet.
  Future<String?> _compose({String initial = '', required String action}) {
    final l = AppLocalizations.of(context);
    final text = TextEditingController(text: initial);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: text,
              autofocus: true,
              minLines: 4,
              maxLines: 10,
              maxLength: 60000,
              decoration: InputDecoration(hintText: l.pullsPlaceholder),
            ),
            const SizedBox(height: 6),
            FilledButton(
              onPressed: () {
                final b = text.text.trim();
                if (b.isNotEmpty) Navigator.pop(ctx, b);
              },
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }

  /// A comment of your own for the review, kept as a draft like agnts's.
  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final body = await _compose(action: l.pullsComment);
    if (body == null) return;
    await _run(
      () => _api.addReviewDraft(
        key: _key,
        addReviewDraftRequest: AddReviewDraftRequest(body: body, headSha: widget.ticket.pull?.headSha),
      ),
    );
  }

  Future<void> _edit(ReviewDraft d) async {
    final l = AppLocalizations.of(context);
    final body = await _compose(initial: d.body, action: l.pullsSave);
    if (body == null || body == d.body) return;
    await _run(
      () => _api.updateReviewDraft(
        key: _key,
        draftId: d.id,
        updateReviewDraftRequest: UpdateReviewDraftRequest(body: body),
      ),
    );
  }

  /// Deletes a person's own comment; it was never published.
  Future<void> _delete(ReviewDraft d) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.draftsDeleteTitle, body: l.draftsDeleteConfirm, action: l.pullsDelete, danger: true)) return;
    await _run(() => _api.deleteReviewDraft(key: _key, draftId: d.id));
  }

  Future<void> _dismiss(ReviewDraft d) async {
    final l = AppLocalizations.of(context);
    final text = TextEditingController();
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.draftsReasonLabel, style: TextStyle(fontSize: 13.5, color: Agnts.of(ctx).ink3)),
            const SizedBox(height: 6),
            TextField(
              controller: text,
              autofocus: true,
              maxLength: 1000,
              decoration: InputDecoration(hintText: l.draftsReasonHint),
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: () => Navigator.pop(ctx, text.text.trim()), child: Text(l.draftsDismiss)),
          ],
        ),
      ),
    );
    if (reason == null) return;
    await _set(d, UpdateReviewDraftRequestStateEnum.dismissed, reason: reason.isEmpty ? null : reason);
  }

  Future<void> _publish(int n) async {
    final l = AppLocalizations.of(context);
    final label = l.draftsPublishBtn(n, _host);
    if (!await confirmAction(context, title: l.draftsPublishTitle(_host), body: l.draftsPublishSub(n, _host), action: label)) return;
    await _run(() async {
      await _api.publishReviewDrafts(key: _key, publishReviewDraftsRequest: PublishReviewDraftsRequest(requestChanges: false));
      ref.invalidate(pullThreadsProvider);
      ref.invalidate(ticketProvider(_key));
    }, done: l.draftsPublishedToast(n, _host));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final canEdit = ref.watch(canEditProvider) && !_locked;
    final drafts = ref.watch(reviewDraftsProvider(_key));
    final all = drafts.value ?? const <ReviewDraft>[];
    if (drafts.hasValue && all.isEmpty) return const SizedBox.shrink();
    int count(ReviewDraftStateEnum s) => all.where((d) => d.state == s).length;
    final accepted = count(ReviewDraftStateEnum.accepted);
    final open = count(ReviewDraftStateEnum.draft);
    bool closed(ReviewDraft d) =>
        d.state == ReviewDraftStateEnum.dismissed || d.state == ReviewDraftStateEnum.outdated || d.state == ReviewDraftStateEnum.published;
    final shown = all.where((d) => _closed || !closed(d)).toList();
    final hidden = all.where(closed).length;

    return Fold(
      key: ValueKey('drafts-$_key-${open > 0}'),
      title: l.draftsTitle,
      hint: drafts.hasValue ? '$accepted / ${all.length}' : null,
      initiallyOpen: open > 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_locked ? l.draftsLockedSub : l.draftsSub(_host), style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3)),
          const SizedBox(height: 10),
          if (drafts.isLoading && !drafts.hasValue)
            Text(l.commonLoading, style: TextStyle(color: c.ink3))
          else if (drafts.hasError && !drafts.hasValue)
            Text(errorMessage(drafts.error!, l.commonError), style: TextStyle(color: c.badInk)),
          if (canEdit)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (open > 0) ...[
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => _api.acceptAllReviewDrafts(
                              key: _key,
                              acceptAllReviewDraftsRequest: AcceptAllReviewDraftsRequest(
                                minSeverity: AcceptAllReviewDraftsRequestMinSeverityEnum.major,
                              ),
                            ),
                          ),
                    child: Text(l.draftsAcceptMajor),
                  ),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => _api.acceptAllReviewDrafts(key: _key, acceptAllReviewDraftsRequest: AcceptAllReviewDraftsRequest()),
                          ),
                    child: Text(l.draftsAcceptAll),
                  ),
                ],
                OutlinedButton(onPressed: _busy ? null : _add, child: Text(l.pullsAddComment)),
                if (open > 0 || accepted > 0)
                  FilledButton(
                    onPressed: _busy || accepted == 0 ? null : () => _publish(accepted),
                    child: Text(l.draftsPublishBtn(accepted, _host)),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          for (final d in shown) _draft(context, d, canEdit),
          if (hidden > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: () => setState(() => _closed = !_closed), child: Text(l.draftsShowClosed(hidden.toString()))),
            ),
        ],
      ),
    );
  }

  Widget _draft(BuildContext context, ReviewDraft d, bool canEdit) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (stateText, tone) = switch (d.state) {
      ReviewDraftStateEnum.draft => (l.draftsState_draft, Tone.gray),
      ReviewDraftStateEnum.accepted => (l.draftsState_accepted, Tone.ok),
      ReviewDraftStateEnum.publishing => (l.draftsState_publishing, Tone.info),
      ReviewDraftStateEnum.dismissed => (l.draftsState_dismissed, Tone.gray),
      ReviewDraftStateEnum.published => (l.draftsState_published, Tone.info),
      ReviewDraftStateEnum.outdated => (l.draftsState_outdated, Tone.warn),
    };
    final sevTone = switch (d.severity) {
      'blocker' => Tone.bad,
      'major' => Tone.warn,
      'minor' => Tone.info,
      _ => Tone.gray,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: d.state == ReviewDraftStateEnum.accepted ? c.okInk : c.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                d.kind == ReviewDraftKindEnum.comment ? (d.author ?? l.draftsSomeone) : 'agnts',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              if (d.kind == ReviewDraftKindEnum.finding && d.severity != null) ToneBadge(d.severity!, sevTone, small: true),
              if (d.kind == ReviewDraftKindEnum.summary) ToneBadge(l.draftsSummary, Tone.gray, small: true),
              ToneBadge(stateText, tone, small: true),
              if (d.edited) Text('· ${l.draftsEdited}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
              if (d.path != null)
                Text(
                  '${d.path}${d.line != null ? ':${d.line}' : ''}',
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                ),
            ],
          ),
          if (d.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l.draftsFailed(d.error!), style: TextStyle(color: c.badInk, fontSize: 13)),
            ),
          if (d.state == ReviewDraftStateEnum.dismissed && d.dismissReason != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l.draftsDismissedBecause(d.dismissReason!), style: TextStyle(color: c.ink3, fontSize: 13)),
            ),
          if (d.state == ReviewDraftStateEnum.outdated)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l.draftsOutdatedHint, style: TextStyle(color: c.ink3, fontSize: 13)),
            ),
          Padding(padding: const EdgeInsets.only(top: 6), child: ReportMarkdown(d.body)),
          if (canEdit && d.state != ReviewDraftStateEnum.publishing && d.state != ReviewDraftStateEnum.published)
            Wrap(
              children: [
                if (d.state == ReviewDraftStateEnum.draft) ...[
                  TextButton(
                    onPressed: _busy ? null : () => _set(d, UpdateReviewDraftRequestStateEnum.accepted),
                    child: Text(l.draftsAccept),
                  ),
                  TextButton(onPressed: _busy ? null : () => _edit(d), child: Text(l.pullsEdit)),
                  if (d.kind != ReviewDraftKindEnum.comment)
                    TextButton(onPressed: _busy ? null : () => _dismiss(d), child: Text(l.draftsDismiss)),
                ] else if (d.state == ReviewDraftStateEnum.accepted) ...[
                  TextButton(onPressed: _busy ? null : () => _set(d, UpdateReviewDraftRequestStateEnum.draft), child: Text(l.draftsUndo)),
                  TextButton(onPressed: _busy ? null : () => _edit(d), child: Text(l.pullsEdit)),
                ] else if (d.state == ReviewDraftStateEnum.dismissed || d.state == ReviewDraftStateEnum.outdated)
                  TextButton(onPressed: _busy ? null : () => _set(d, UpdateReviewDraftRequestStateEnum.draft), child: Text(l.draftsReopen)),
                if (d.kind == ReviewDraftKindEnum.comment)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: c.badInk),
                    onPressed: _busy ? null : () => _delete(d),
                    child: Text(l.pullsDelete),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

String _hostOf(String url) => _host(url);
