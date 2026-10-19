import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// How each reviewer reviews: profiles and the notes not learned yet.
final reviewersProvider = FutureProvider<Reviewers>((ref) async {
  return (await requireApi(ref).getReviewsApi().listReviewers()).data!;
});

/// Whether a review is the sync's, held until someone presses Review.
bool reviewNotStarted(Ticket t) => t.state == TicketState.new_ && t.held == true;

/// Review tickets by group: not started, waiting for you, in progress,
/// finished (the last 20).
({List<Ticket> notStarted, List<Ticket> waiting, List<Ticket> inProgress, List<Ticket> finished}) reviewGroups(List<Ticket> tickets) {
  final reviews = tickets.where((t) => t.kind == TicketKind.review).toList();
  bool finished(Ticket t) => t.state == TicketState.done || t.state == TicketState.rejected;
  return (
    notStarted: reviews.where(reviewNotStarted).toList(),
    waiting: reviews.where((t) => t.state == TicketState.waitingForReview).toList(),
    inProgress: reviews.where((t) => t.state != TicketState.waitingForReview && !finished(t) && !reviewNotStarted(t)).toList(),
    finished: reviews.where(finished).take(20).toList(),
  );
}

/// The pull requests agnts reviews for you, a sync, how you review
/// (profiles and notes), and how it picks them up. Opened from More.
class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  ReviewSync? _lastSync;
  bool _syncing = false;
  bool _busy = false;
  final _profiles = <String, TextEditingController>{};
  final _notes = <String, TextEditingController>{};
  final _newLogin = TextEditingController();

  @override
  void initState() {
    super.initState();
    _newLogin.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final t in [..._profiles.values, ..._notes.values, _newLogin]) {
      t.dispose();
    }
    super.dispose();
  }

  TextEditingController _note(String login) => _notes.putIfAbsent(login, () => TextEditingController()..addListener(() => setState(() {})));
  TextEditingController _profile(String login, String initial) =>
      _profiles.putIfAbsent(login, () => TextEditingController(text: initial)..addListener(() => setState(() {})));

  ReviewsApi get _api => ref.read(apiProvider)!.getReviewsApi();

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(reviewersProvider);
      if (done != null && mounted) showSnack(context, done);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sync() async {
    final l = AppLocalizations.of(context);
    setState(() => _syncing = true);
    try {
      final r = (await _api.syncReviews()).data;
      setState(() => _lastSync = r);
      ref.invalidate(ticketsProvider);
      ref.invalidate(dashboardProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _start(String key) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider)!.getTicketsApi().startTicket(key: key);
      ref.invalidate(ticketsProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveSettings(Settings s, Map<String, dynamic> Function(Map<String, dynamic>) change) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(apiProvider)!.getSettingsApi().putSettings(settings: Settings.fromJson(change(s.toJson())));
      ref.invalidate(settingsProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final tickets = ref.watch(ticketsProvider('all'));
    final canEdit = ref.watch(canEditProvider);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      body: AsyncBody<List<Ticket>>(
        value: tickets,
        onRefresh: () {
          ref.invalidate(reviewersProvider);
          ref.invalidate(settingsProvider);
          return ref.refresh(ticketsProvider('all').future);
        },
        builder: (all) {
          final g = reviewGroups(all);
          final any = g.notStarted.isNotEmpty || g.waiting.isNotEmpty || g.inProgress.isNotEmpty || g.finished.isNotEmpty;
          final sync = _lastSync;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              PageHeader(title: l.reviewsTitle, sub: l.reviewsLede, long: true),
              if (canEdit)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: FilledButton(onPressed: _syncing ? null : _sync, child: Text(_syncing ? l.reviewsSyncing : l.reviewsSync)),
                ),
              if (sync != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: HelpBox(
                    l.reviewsSynced('${sync.open}', '${sync.repos}', '${sync.created}', '${sync.rereview}', '${sync.closed}'),
                    tone: sync.errors.isEmpty ? Tone.info : Tone.warn,
                    child: sync.errors.isEmpty
                        ? null
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.reviewsSyncErrors),
                            for (final e in sync.errors) Text('• $e', style: const TextStyle(fontSize: 13.5)),
                          ]),
                  ),
                ),
              if (!any)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HCard(child: Text(l.reviewsEmptyAll, style: TextStyle(color: c.ink3))))
              else
                for (final (title, rows) in [(l.reviewsNotStarted, g.notStarted), (l.reviewsWaiting, g.waiting), (l.reviewsInProgress, g.inProgress), (l.reviewsFinished, g.finished)]) ...[
                  SectionHeader(title, trailing: rows.isEmpty ? null : Text('${rows.length}')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: rows.isEmpty
                        ? HCard(child: Text(l.reviewsEmpty, style: TextStyle(color: c.ink3)))
                        : ListGroup(children: [
                            for (final t in rows) _ReviewRow(t, onStart: canEdit && reviewNotStarted(t) && !_busy ? () => _start(t.key) : null),
                          ]),
                  ),
                ],
              _howYouReview(l, c, all, canEdit),
              ..._settings(l, canEdit),
            ],
          );
        },
      ),
    );
  }

  Widget _howYouReview(AppLocalizations l, Agnts c, List<Ticket> all, bool canEdit) {
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.35);
    final h3 = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink);
    final reviewers = ref.watch(reviewersProvider);
    final known = reviewers.value?.reviewers ?? const <Reviewer>[];
    // Logins agnts reviews for: those it knows, and those of the pull requests it has.
    final logins = {
      ...known.map((r) => r.login),
      for (final t in all)
        if (t.kind == TicketKind.review && t.pull != null && t.pull!.login.isNotEmpty) t.pull!.login,
    }.toList()
      ..sort();
    Reviewer? of(String login) => known.where((r) => r.login == login).firstOrNull;
    final locked = _busy || !canEdit;

    Widget addNote(String login, TextEditingController note) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 12),
          Text(l.reviewsAddNote, style: hint),
          const SizedBox(height: 6),
          TextField(
            controller: note,
            enabled: !locked,
            minLines: 2,
            maxLines: 6,
            maxLength: 4000,
            decoration: InputDecoration(hintText: l.reviewsNotePlaceholder, counterText: ''),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: locked || login.isEmpty || note.text.trim().isEmpty
                  ? null
                  : () => _run(() async {
                        await _api.addReviewerNote(reviewerNoteInput: ReviewerNoteInput(login: login, note: note.text.trim()));
                        note.clear();
                      }, done: l.reviewsNoteAdded),
              child: Text(l.reviewsAddNote),
            ),
          ),
        ]);

    final children = <Widget>[
      Text(l.reviewsHowSub, style: hint),
      const SizedBox(height: 8),
      if (reviewers.isLoading && !reviewers.hasValue)
        const LinearProgressIndicator()
      else if (logins.isEmpty) ...[
        Text(l.reviewsNoReviewers, style: hint),
        const SizedBox(height: 12),
        TextField(controller: _newLogin, enabled: !locked, decoration: InputDecoration(hintText: l.reviewsLogin)),
        addNote(_newLogin.text.trim(), _note('')),
      ],
      for (final (i, login) in logins.indexed) ...[
        if (i > 0) Divider(height: 28, color: c.line2),
        Text.rich(TextSpan(children: [
          TextSpan(text: '@$login', style: h3),
          if ((of(login)?.notesFolded ?? 0) > 0) TextSpan(text: ' · ${l.reviewsFolded(of(login)!.notesFolded)}', style: hint),
        ])),
        const SizedBox(height: 8),
        Text('${l.reviewsProfile} · ${l.reviewsProfileHint}', style: hint),
        const SizedBox(height: 6),
        Builder(builder: (_) {
          final p = _profile(login, of(login)?.profile ?? '');
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextField(
              controller: p,
              enabled: !locked,
              minLines: 4,
              maxLines: 12,
              maxLength: 8000,
              style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13),
              decoration: const InputDecoration(counterText: ''),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: locked || p.text == (of(login)?.profile ?? '')
                    ? null
                    : () => _run(
                          () => _api.saveReviewerProfile(login: login, reviewerProfileInput: ReviewerProfileInput(profile: p.text)),
                          done: l.reviewsProfileSaved,
                        ),
                child: Text(l.reviewsSaveProfile),
              ),
            ),
          ]);
        }),
        if ((of(login)?.pending ?? const []).isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l.reviewsPending, style: h3.copyWith(fontSize: 14)),
          const SizedBox(height: 6),
          for (final n in of(login)!.pending) _NoteTile(n, onDelete: locked ? null : () => _run(() => _api.deleteReviewerNote(id: n.id))),
        ],
        addNote(login, _note(login)),
      ],
    ];
    return Section(title: l.reviewsHowTitle, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children));
  }

  List<Widget> _settings(AppLocalizations l, bool canEdit) {
    final s = ref.watch(settingsProvider).value;
    if (s == null) return const [];
    final pr = s.pullReviews ??
        PullReviewSettings(enabled: false, reviewRequested: true, all: true, skipDrafts: true, rereview: true, mergeMethod: PullReviewSettingsMergeMethodEnum.merge);
    final prc = s.prComments ?? PRCommentSettings(attribution: true, learnFromComments: true, resolveFixed: true, autoAddress: false);
    void setPr(String k, Object v) => _saveSettings(s, (j) => j..['pullReviews'] = {...pr.toJson(), k: v});
    void setPrc(String k, bool v) => _saveSettings(s, (j) => j..['prComments'] = {...prc.toJson(), k: v});
    Widget sw(String label, String help, bool value, void Function(bool) on) => ListRow(
          title: label,
          subtitle: help,
          trailing: Switch.adaptive(value: value, onChanged: canEdit ? on : null),
        );
    return [
      SectionHeader(l.reviewsSettingsTitle),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListGroup(children: [
          sw(l.reviewsEnabled, l.reviewsEnabledHelp, pr.enabled, (v) => setPr('enabled', v)),
          sw(l.reviewsReviewRequested, l.reviewsReviewRequestedHelp, pr.reviewRequested, (v) => setPr('reviewRequested', v)),
          sw(l.reviewsAll, l.reviewsAllHelp, pr.all ?? true, (v) => setPr('all', v)),
          sw(l.reviewsSkipDrafts, l.reviewsSkipDraftsHelp, pr.skipDrafts, (v) => setPr('skipDrafts', v)),
          sw(l.reviewsRereview, l.reviewsRereviewHelp, pr.rereview, (v) => setPr('rereview', v)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.reviewsMergeMethod, style: const TextStyle(fontSize: 15)),
              Text(l.reviewsMergeMethodHelp, style: TextStyle(fontSize: 13, color: Agnts.of(context).ink3)),
              const SizedBox(height: 8),
              Segmented<PullReviewSettingsMergeMethodEnum>(
                full: true,
                options: [
                  (PullReviewSettingsMergeMethodEnum.merge, l.reviewsMerge_merge),
                  (PullReviewSettingsMergeMethodEnum.squash, l.reviewsMerge_squash),
                  (PullReviewSettingsMergeMethodEnum.rebase, l.reviewsMerge_rebase),
                ],
                value: pr.mergeMethod,
                onChanged: (v) {
                  if (canEdit) setPr('mergeMethod', v.value);
                },
              ),
            ]),
          ),
        ]),
      ),
      SectionHeader(l.pullsSettingsTitle),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListGroup(children: [
          sw(l.pullsSet_attribution, l.pullsSet_attributionHelp, prc.attribution, (v) => setPrc('attribution', v)),
          sw(l.pullsSet_learnFromComments, l.pullsSet_learnFromCommentsHelp, prc.learnFromComments, (v) => setPrc('learnFromComments', v)),
          sw(l.pullsSet_resolveFixed, l.pullsSet_resolveFixedHelp, prc.resolveFixed, (v) => setPrc('resolveFixed', v)),
          sw(l.pullsSet_autoAddress, l.pullsSet_autoAddressHelp, prc.autoAddress, (v) => setPrc('autoAddress', v)),
        ]),
      ),
    ];
  }
}

/// One review ticket: repository and pull request number, title, author
/// and why it came, its state.
class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.t, {this.onStart});
  final Ticket t;

  /// Starts a review that is not started yet; null hides the button.
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final p = t.pull;
    final why = switch (p?.why) {
      PullRequestWhyEnum.assigned => l.reviewsWhy_assigned,
      PullRequestWhyEnum.reviewRequested => l.reviewsWhy_review_requested,
      PullRequestWhyEnum.open => l.reviewsWhy_open,
      PullRequestWhyEnum.own => l.reviewsWhy_own,
      PullRequestWhyEnum.manual => l.reviewsWhy_manual,
      null => null,
    };
    return InkWell(
      onTap: () => context.push('/tickets/${t.key}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                [t.repoName ?? '—', if (p != null) '#${p.number}'].join(' '),
                style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3),
              ),
              const SizedBox(height: 2),
              Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink)),
              if (p != null)
                Text(
                  [l.reviewsBy(p.author), ?why].join(' · '),
                  style: TextStyle(fontSize: 13, color: c.ink3),
                ),
            ]),
          ),
          const SizedBox(width: 8),
          if (onStart != null)
            FilledButton(onPressed: onStart, child: Text(l.reviewsStart))
          else
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              StateBadge(t.state, kind: t.kind),
              if (t.mergedAt != null) ...[const SizedBox(height: 4), ToneBadge(l.ticketMerged, Tone.ok, small: true)],
            ]),
        ]),
      ),
    );
  }
}

/// A reviewer note not learned yet, with a delete button.
class _NoteTile extends StatelessWidget {
  const _NoteTile(this.n, {this.onDelete});
  final ReviewerNote n;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final kind = switch (n.kind) {
      ReviewerNoteKindEnum.rereview => l.reviewsNoteKind_rereview,
      ReviewerNoteKindEnum.dismissed => l.reviewsNoteKind_dismissed,
      ReviewerNoteKindEnum.manual => l.reviewsNoteKind_manual,
      _ => n.kind.value,
    };
    final d = DateTime.now().difference(n.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(border: Border.all(color: c.line), borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(kind, style: TextStyle(fontSize: 12.5, color: c.ink3)),
              if (n.ticketKey != null)
                GestureDetector(
                  onTap: () => context.push('/tickets/${n.ticketKey}'),
                  child: Text(n.ticketKey!, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.primary)),
                ),
              Text(d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d)), style: TextStyle(fontSize: 12.5, color: c.ink3)),
            ]),
            const SizedBox(height: 4),
            Text(n.note, style: TextStyle(fontSize: 14, color: c.ink, height: 1.4)),
          ]),
        ),
        IconButton(
          tooltip: l.reviewsDeleteNote,
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline_rounded, size: 20, color: c.ink3),
        ),
      ]),
    );
  }
}
