import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../admin/admin_widgets.dart' show confirmAction;
import '../ci/ci_screen.dart' show ciAgo;
import '../tickets/diff_lines.dart';
import '../tickets/kinds.dart' show ReportMarkdown;
import '../tickets/pull_comments.dart' show pullThreadsProvider, reviewDraftsProvider;
import 'pull_widgets.dart';
import 'pulls_data.dart';
import 'repo_pulls.dart' show askReview;
import '../account/account_widgets.dart' show openLink;

enum _View { conversation, files }

/// One pull request (GitLab merge request) as it stands on the git host:
/// its description, conversation and diff, with comments made here going
/// out as the git host token's user. "Review with agnts" asks for a review
/// of it; the review's comments stay drafts here until accepted and published.
class PullScreen extends ConsumerStatefulWidget {
  const PullScreen({super.key, required this.repoId, required this.number});
  final int repoId;
  final int number;

  @override
  ConsumerState<PullScreen> createState() => _PullScreenState();
}

class _PullScreenState extends ConsumerState<PullScreen> implements PullOps {
  bool _busy = false;
  bool _resolved = false;
  bool _closed = false;
  _View? _view;
  Timer? _poll;
  bool _fast = false;

  (int, int) get _k => (widget.repoId, widget.number);
  PullsApi get _pulls => ref.read(apiProvider)!.getPullsApi();
  ReviewsApi get _reviews => ref.read(apiProvider)!.getReviewsApi();
  PullDetail? get _d => ref.read(pullDetailProvider(_k)).value;
  String? get _review => _d == null ? null : latestReview(_d!)?.key;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  /// Refreshes faster while agnts is reviewing, so its drafts show up when ready.
  void _schedule() {
    _poll?.cancel();
    _poll = Timer.periodic(Duration(seconds: _fast ? 10 : 60), (_) {
      ref.invalidate(pullDetailProvider(_k));
      ref.invalidate(pullThreadsProvider(_k));
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(pullThreadsProvider(_k));
    final key = _review;
    if (key != null) ref.invalidate(reviewDraftsProvider(key));
    await ref.refresh(pullDetailProvider(_k).future).then((_) {});
  }

  Future<void> _run(Future<void> Function() action, {String? done, bool drafts = false}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(pullThreadsProvider(_k));
      if (drafts) {
        ref.invalidate(pullDetailProvider(_k));
        final key = _review;
        if (key != null) {
          ref.invalidate(reviewDraftsProvider(key));
          ref.invalidate(ticketProvider(key));
        }
      }
      if (done != null && mounted) showSnack(context, done);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // PullOps

  @override
  bool get busy => _busy;

  @override
  bool get canEdit => ref.read(canEditProvider);

  @override
  String get postsAs {
    final l = AppLocalizations.of(context);
    final d = _d;
    final host = hostName(d?.provider);
    final login = d?.login ?? '';
    return login.isNotEmpty ? l.pullsPostsAs(login, host) : l.pullsPostsAsToken(host);
  }

  @override
  bool get draftsEditable => canEdit && _d != null && !pullDraftsLocked(_d!);

  Future<void> _comment() async {
    final l = AppLocalizations.of(context);
    final r = await composeComment(context, action: l.pullsComment, as: postsAs);
    if (r == null) return;
    await _run(
      () => _pulls.addPullComment(
        id: widget.repoId,
        number: widget.number,
        newPullComment: NewPullComment(body: r.body),
      ),
    );
  }

  @override
  Future<void> reply(PullThread th) async {
    final l = AppLocalizations.of(context);
    final r = await composeComment(context, action: l.pullsReply, as: postsAs);
    if (r == null) return;
    await _run(
      () => _pulls.replyPullThread(
        id: widget.repoId,
        number: widget.number,
        replyPullThreadRequest: ReplyPullThreadRequest(threadId: th.id, body: r.body),
      ),
    );
  }

  @override
  Future<void> edit(PullComment c) async {
    final l = AppLocalizations.of(context);
    final r = await composeComment(context, initial: c.body, action: l.pullsSave);
    if (r == null) return;
    await _run(
      () => _pulls.editPullComment(
        id: widget.repoId,
        number: widget.number,
        editPullCommentRequest: EditPullCommentRequest(commentId: c.id, body: r.body),
      ),
    );
  }

  @override
  Future<void> delete(PullComment c) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(context, title: l.pullsDeleteTitle, body: l.pullsDeleteConfirm, action: l.pullsDelete, danger: true)) return;
    await _run(
      () => _pulls.deletePullComment(id: widget.repoId, number: widget.number, commentId: c.id),
      done: l.pullsDeleted,
    );
  }

  @override
  Future<void> resolve(PullThread th) => _run(
    () => _pulls.resolvePullThread(
      id: widget.repoId,
      number: widget.number,
      resolvePullThreadRequest: ResolvePullThreadRequest(threadId: th.id, resolved: !th.resolved),
    ),
  );

  @override
  Future<void> commentOnLine(FileChange f, DiffLine line) async {
    final l = AppLocalizations.of(context);
    final d = _d;
    if (d == null) return;
    final key = _review;
    // With a review of it, a comment on a line can be kept as a draft of the review.
    final drafting = key != null && draftsEditable && line.kind != DiffKind.del;
    final r = await composeComment(
      context,
      action: l.pullsComment,
      as: postsAs,
      alt: drafting ? l.draftsAddToReview : null,
      quote: '${f.path}:${line.neu ?? line.old}\n${line.text}',
    );
    if (r == null) return;
    if (r.toReview && key != null) {
      await _run(
        () => _reviews.addReviewDraft(
          key: key,
          addReviewDraftRequest: AddReviewDraftRequest(body: r.body, path: f.path, line: line.neu, headSha: d.pull.headSha),
        ),
        done: l.draftsAddedToast,
        drafts: true,
      );
    } else {
      await _run(
        () => _pulls.addPullComment(
          id: widget.repoId,
          number: widget.number,
          newPullComment: lineComment(line, body: r.body, path: f.path, headSha: d.pull.headSha),
        ),
      );
    }
  }

  @override
  Future<void> setDraft(ReviewDraft d, UpdateReviewDraftRequestStateEnum state, {String? reason}) async {
    final key = _review;
    if (key == null) return;
    await _run(
      () => _reviews.updateReviewDraft(
        key: key,
        draftId: d.id,
        updateReviewDraftRequest: UpdateReviewDraftRequest(state: state, dismissReason: reason),
      ),
      drafts: true,
    );
  }

  @override
  Future<void> dismissDraft(ReviewDraft d) async {
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
    await setDraft(d, UpdateReviewDraftRequestStateEnum.dismissed, reason: reason.isEmpty ? null : reason);
  }

  @override
  Future<void> editDraft(ReviewDraft d) async {
    final l = AppLocalizations.of(context);
    final key = _review;
    if (key == null) return;
    final r = await composeComment(context, initial: d.body, action: l.pullsSave);
    if (r == null) return;
    await _run(
      () => _reviews.updateReviewDraft(
        key: key,
        draftId: d.id,
        updateReviewDraftRequest: UpdateReviewDraftRequest(body: r.body),
      ),
      drafts: true,
    );
  }

  @override
  Future<void> deleteDraft(ReviewDraft d) async {
    final l = AppLocalizations.of(context);
    final key = _review;
    if (key == null) return;
    if (!await confirmAction(context, title: l.draftsDeleteTitle, body: l.draftsDeleteConfirm, action: l.pullsDelete, danger: true)) return;
    await _run(() => _reviews.deleteReviewDraft(key: key, draftId: d.id), drafts: true);
  }

  Future<void> _acceptAll(AcceptAllReviewDraftsRequestMinSeverityEnum? min) async {
    final key = _review;
    if (key == null) return;
    await _run(
      () => _reviews.acceptAllReviewDrafts(
        key: key,
        acceptAllReviewDraftsRequest: AcceptAllReviewDraftsRequest(minSeverity: min),
      ),
      drafts: true,
    );
  }

  /// Publishes the accepted drafts on the git host as one review, after
  /// showing them; on GitHub it can request changes (not on your own).
  Future<void> _publish(PullDetail d, List<ReviewDraft> accepted) async {
    final l = AppLocalizations.of(context);
    final key = _review;
    if (key == null) return;
    final host = hostName(d.provider);
    final head = d.pull.headSha;
    final old = accepted.where((x) => head.isNotEmpty && x.headSha.isNotEmpty && x.headSha != head).firstOrNull;
    final own = (d.login ?? '').isNotEmpty && d.login!.toLowerCase() == d.pull.author.toLowerCase();
    final canRequest = d.provider == PullDetailProviderEnum.github && !own;
    var changes = false;
    final go = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final c = Agnts.of(ctx);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.draftsPublishTitle(host), style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(l.draftsPublishSub(accepted.length, host), style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3)),
                  if (old != null) ...[
                    const SizedBox(height: 10),
                    HelpBox(l.draftsHeadMoved(old.headSha.substring(0, 7), head.length >= 7 ? head.substring(0, 7) : head, host), tone: Tone.warn),
                  ],
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.35),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final x in accepted)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ToneBadge(x.kind == ReviewDraftKindEnum.finding ? (x.severity ?? '') : _kind(l, x.kind), Tone.gray, small: true),
                                Text(x.title ?? (x.body.length > 80 ? x.body.substring(0, 80) : x.body), style: TextStyle(fontSize: 13.5, color: c.ink)),
                                if (x.path != null)
                                  Text(
                                    '${x.path}${x.line != null ? ':${x.line}' : ''}',
                                    style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (canRequest)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.pullsRequestChanges),
                      value: changes,
                      onChanged: (v) => setSheet(() => changes = v),
                    ),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.draftsPublishBtn(accepted.length, host))),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (go != true || !mounted) return;
    await _run(
      () => _reviews.publishReviewDrafts(
        key: key,
        publishReviewDraftsRequest: PublishReviewDraftsRequest(requestChanges: changes),
      ),
      done: l.draftsPublishedToast(accepted.length, host),
      drafts: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final pull = ref.watch(pullDetailProvider(_k));
    final d = pull.value;
    final fast = d != null && pullReviewing(d);
    if (fast != _fast) {
      _fast = fast;
      _schedule();
    }
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: '#${widget.number}',
        onBack: () => context.canPop() ? context.pop() : context.go('/repos/${widget.repoId}'),
      ),
      body: AsyncBody<PullDetail>(
        value: pull,
        onRefresh: _refresh,
        builder: (d) {
          final review = latestReview(d);
          final drafts = review == null ? null : (ref.watch(reviewDraftsProvider(review.key)).value ?? d.drafts);
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _header(context, d),
              _history(context, d),
              if ((d.body ?? '').trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: HCard(child: ReportMarkdown(d.body!)),
                ),
              if (d.filesError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: HelpBox(l.pullsFilesError(d.filesError!), tone: Tone.warn),
                ),
              if (pullReviewing(d)) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: HelpBox(l.draftsReviewingNow(review?.key ?? ''))),
              if (drafts != null && drafts.isNotEmpty) _draftsPanel(context, d, drafts),
              ..._conversation(context, d, drafts),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, PullDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final p = d.pull;
    final canEdit = ref.watch(canEditProvider);
    final host = hostName(d.provider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(p.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.15)),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 13, color: c.ink3),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ToneBadge(pullStateLabel(l, p.state.value), pullStateTone(p.state)),
                if (p.draft) ToneBadge(l.pullsDraft, Tone.gray),
                Text(p.author),
                Text(
                  '${p.headRef} → ${p.baseRef}',
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3),
                ),
                Text(d.repoName),
                Text(l.pullsUpdated(ciAgo(l, p.updatedAt))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canEdit && pullCanAsk(d))
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          if (await askReview(context, ref, repoId: widget.repoId, number: widget.number)) {
                            ref.invalidate(pullDetailProvider(_k));
                          }
                        },
                  child: Text(latestReview(d) != null ? l.draftsReviewAgainBtn : l.draftsReviewWithBtn),
                ),
              if (d.own && d.ticketKey != null)
                OutlinedButton(
                  onPressed: () => context.push('/tickets/${d.ticketKey}'),
                  child: Text(l.pullsOwnTicket(d.ticketKey!)),
                ),
              OutlinedButton(onPressed: () => openLink(context, p.url), child: Text(l.mpullsCopyLink(host))),
            ],
          ),
        ],
      ),
    );
  }

  /// agnts's reviews of the pull request, newest first; each opens its ticket.
  Widget _history(BuildContext context, PullDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final reviews = d.reviews ?? const <PullReviewRef>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.reviewsHistory, trailing: reviews.isEmpty ? null : Text('${reviews.length}')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: reviews.isEmpty
            ? HCard(child: Text(l.reviewsHistoryEmpty, style: TextStyle(color: c.ink3)))
            : ListGroup(children: [
                for (final (i, r) in reviews.indexed)
                  ListRow(
                    title: r.key,
                    subtitle: [
                      if ((r.headSha ?? '').length >= 7) l.reviewsReviewedAt(r.headSha!.substring(0, 7)),
                      ciAgo(l, r.createdAt),
                    ].join(' · '),
                    trailing: Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      if (i == 0 && (r.headSha ?? '').isNotEmpty && r.headSha != d.pull.headSha) ToneBadge(l.reviewsNewCommits, Tone.warn, small: true),
                      StateBadge(r.state, kind: TicketKind.review),
                    ]),
                    onTap: () => context.push('/tickets/${r.key}'),
                  ),
              ]),
      ),
    ]);
  }

  Widget _draftsPanel(BuildContext context, PullDetail d, List<ReviewDraft> drafts) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final host = hostName(d.provider);
    final locked = pullDraftsLocked(d);
    final editable = draftsEditable;
    int count(ReviewDraftStateEnum s) => drafts.where((x) => x.state == s).length;
    final n = {for (final s in ReviewDraftStateEnum.values) s: count(s)};
    final accepted = drafts.where((x) => x.state == ReviewDraftStateEnum.accepted).toList();
    bool closed(ReviewDraft x) =>
        x.state == ReviewDraftStateEnum.dismissed || x.state == ReviewDraftStateEnum.outdated || x.state == ReviewDraftStateEnum.published;
    final listed = listedDrafts(drafts, d.files, d.pull.headSha);
    final shown = listed.where((x) => _closed || !closed(x)).toList();
    final hidden = listed.where(closed).length;
    final open = n[ReviewDraftStateEnum.draft]!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: HCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.draftsTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ToneBadge(l.draftsNAccepted('${n[ReviewDraftStateEnum.accepted]}'), Tone.ok, small: true),
                ToneBadge(l.draftsNDraft(open), Tone.gray, small: true),
                if (n[ReviewDraftStateEnum.dismissed]! > 0) ToneBadge(l.draftsNDismissed('${n[ReviewDraftStateEnum.dismissed]}'), Tone.gray, small: true),
                if (n[ReviewDraftStateEnum.published]! > 0) ToneBadge(l.draftsNPublished('${n[ReviewDraftStateEnum.published]}'), Tone.info, small: true),
                if (n[ReviewDraftStateEnum.outdated]! > 0) ToneBadge(l.draftsNOutdated('${n[ReviewDraftStateEnum.outdated]}'), Tone.warn, small: true),
              ],
            ),
            const SizedBox(height: 8),
            Text(locked ? l.draftsLockedSub : l.draftsSub(host), style: TextStyle(fontSize: 13.5, height: 1.45, color: c.ink3)),
            if (editable) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (open > 0) ...[
                    OutlinedButton(
                      onPressed: _busy ? null : () => _acceptAll(AcceptAllReviewDraftsRequestMinSeverityEnum.major),
                      child: Text(l.draftsAcceptMajor),
                    ),
                    OutlinedButton(onPressed: _busy ? null : () => _acceptAll(null), child: Text(l.draftsAcceptAll)),
                  ],
                  FilledButton(
                    onPressed: _busy || accepted.isEmpty ? null : () => _publish(d, accepted),
                    child: Text(l.draftsPublishBtn(accepted.length, host)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            for (final x in shown) DraftCard(draft: x, ops: this),
            if (hidden > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(onPressed: () => setState(() => _closed = !_closed), child: Text(l.draftsShowClosed('$hidden'))),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _conversation(BuildContext context, PullDetail d, List<ReviewDraft>? drafts) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final canEdit = ref.watch(canEditProvider);
    final threads = ref.watch(pullThreadsProvider(_k));
    final all = threads.value ?? const <PullThread>[];
    // Open on the diff while agnts's drafts wait for a decision.
    final view = _view ?? (drafts?.any((x) => x.state == ReviewDraftStateEnum.draft) ?? false ? _View.files : _View.conversation);
    final resolvedN = all.where((th) => th.resolved).length;
    final openN = all.where((th) => th.resolvable && !th.resolved).length;
    Widget pad(Widget w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: w);
    final out = <Widget>[
      const SizedBox(height: 16),
      pad(
        Segmented<_View>(
          full: true,
          options: [
            (_View.conversation, '${l.pullsConversation} ${threads.hasValue ? all.length : ''}'.trim()),
            (_View.files, '${l.pullsFiles} ${d.files.length}'),
          ],
          value: view,
          onChanged: (v) => setState(() => _view = v),
        ),
      ),
      if (openN > 0)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(alignment: Alignment.centerLeft, child: ToneBadge(l.pullsUnresolvedN(openN), Tone.warn)),
        ),
      const SizedBox(height: 10),
    ];
    if (threads.isLoading && !threads.hasValue) {
      out.add(const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()));
      return out;
    }
    if (threads.hasError && !threads.hasValue) {
      out.add(pad(HelpBox(errorMessage(threads.error!, l.commonError), tone: Tone.bad)));
      return out;
    }
    if (view == _View.conversation) {
      final shown = shownThreads(all, resolved: _resolved);
      if (shown.isEmpty) out.add(pad(Text(l.pullsNoComments, style: TextStyle(color: c.ink3))));
      for (final th in shown) {
        out.add(pad(PullThreadCard(thread: th, ops: this)));
      }
      if (resolvedN > 0) {
        out.add(
          pad(
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _resolved = !_resolved),
                child: Text(_resolved ? l.pullsResolved : l.pullsShowResolved('$resolvedN')),
              ),
            ),
          ),
        );
      }
      if (canEdit) {
        out.add(const SizedBox(height: 6));
        out.add(pad(OutlinedButton(onPressed: _busy ? null : _comment, child: Text(l.pullsAddComment))));
        out.add(
          pad(
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(postsAs, style: TextStyle(fontSize: 12.5, color: c.ink3)),
            ),
          ),
        );
      }
    } else {
      if (d.files.isEmpty) out.add(pad(Text(l.pullsNoFiles, style: TextStyle(color: c.ink3))));
      final byFile = threadsByFile(all);
      for (final f in d.files) {
        out.add(
          pad(
            PullDiffFile(
              key: ValueKey(f.path),
              file: f,
              threads: byFile[f.path] ?? const [],
              ops: this,
              drafts: drafts == null ? null : draftsOnFile(drafts, f.path),
              headSha: d.pull.headSha,
            ),
          ),
        );
      }
    }
    return out;
  }
}

String _kind(AppLocalizations l, ReviewDraftKindEnum k) => switch (k) {
  ReviewDraftKindEnum.summary => l.draftsKind_summary,
  ReviewDraftKindEnum.finding => l.draftsKind_finding,
  ReviewDraftKindEnum.comment => l.draftsKind_comment,
};
