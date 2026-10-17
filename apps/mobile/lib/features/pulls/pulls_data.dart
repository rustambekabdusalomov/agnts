import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../tickets/diff_lines.dart';

/// The pull request states the list filters by, as the API names them.
const pullStates = ['open', 'merged', 'closed', 'all'];

/// The git host sends 30 pull requests a page; a shorter page is the last.
const pullsPerPage = 30;

/// One page of a repository's pull requests: (repository id, state, page).
final repoPullsPageProvider = FutureProvider.family<List<PullItem>, (int, String, int)>((ref, k) async {
  return (await requireApi(ref).getPullsApi().listRepoPulls(id: k.$1, state: k.$2, page: k.$3)).data ?? const [];
});

/// One pull request as it stands on the git host: (repository id, number).
final pullDetailProvider = FutureProvider.family<PullDetail, (int, int)>((ref, k) async {
  return (await requireApi(ref).getPullsApi().getRepoPull(id: k.$1, number: k.$2)).data!;
});

/// "GitHub" or "GitLab", for "posts as … on GitHub".
String hostName(PullDetailProviderEnum? p) => p == PullDetailProviderEnum.gitlab ? 'GitLab' : 'GitHub';

const _busyStates = {TicketState.new_, TicketState.analyzing, TicketState.coding};
const _endStates = {TicketState.done, TicketState.rejected};

/// agnts is reviewing someone else's pull request right now.
bool pullReviewing(PullDetail d) => !d.own && d.ticketKey != null && _busyStates.contains(d.ticketState);

/// A review can be asked for on an open pull request that is not agnts's
/// own, when it has none in progress.
bool pullCanAsk(PullDetail d) =>
    d.pull.state == PullItemStateEnum.open && !d.own && (d.ticketKey == null || _endStates.contains(d.ticketState));

/// The review's drafts can only be read: the pull request is closed or the review dismissed.
bool pullDraftsLocked(PullDetail d) => d.pull.state != PullItemStateEnum.open || d.ticketState == TicketState.rejected;

/// The conversation threads worth showing: system notes ("added 2 commits")
/// say little, and resolved threads fold away unless asked for.
List<PullThread> shownThreads(List<PullThread> all, {required bool resolved}) =>
    all.where((th) => !th.comments.every((c) => c.system) && (resolved || !th.resolved)).toList();

/// Inline threads by file path.
Map<String, List<PullThread>> threadsByFile(List<PullThread> all) {
  final m = <String, List<PullThread>>{};
  for (final th in all) {
    if (th.kind == PullThreadKindEnum.inline && th.path != null) (m[th.path!] ??= []).add(th);
  }
  return m;
}

/// A thread sits under the line it names: a removed line by its old number,
/// any other by its new one.
bool _anchors(PullThread th, DiffLine l) =>
    l.kind == DiffKind.del ? th.line == null && th.oldLine != null && th.oldLine == l.old : th.line != null && th.line == l.neu;

/// Places a file's threads under their diff lines (by line index); outdated
/// ones, or ones whose line is not in the diff any more, are left over.
({Map<int, List<PullThread>> at, List<PullThread> left}) placeThreads(List<DiffLine> lines, List<PullThread> threads) {
  final at = <int, List<PullThread>>{};
  final left = <PullThread>[];
  for (final th in threads) {
    final i = th.outdated ? -1 : lines.indexWhere((l) => (l.neu != null || l.old != null) && _anchors(th, l));
    if (i < 0) {
      left.add(th);
    } else {
      (at[i] ??= []).add(th);
    }
  }
  return (at: at, left: left);
}

/// The drafts placed on one file's diff: live, with a line, not the summary.
List<ReviewDraft> draftsOnFile(List<ReviewDraft> ds, String path) => ds
    .where((d) => d.path == path && d.line != null && d.state != ReviewDraftStateEnum.published && d.kind != ReviewDraftKindEnum.summary)
    .toList();

/// Places drafts under their lines when they are about the version shown;
/// one written on another commit, or on a line outside the diff, is left over.
({Map<int, List<ReviewDraft>> at, List<ReviewDraft> left}) placeDrafts(List<DiffLine> lines, List<ReviewDraft> drafts, String? headSha) {
  final at = <int, List<ReviewDraft>>{};
  final left = <ReviewDraft>[];
  for (final d in drafts) {
    final same = headSha == null || headSha.isEmpty || d.headSha.isEmpty || d.headSha == headSha;
    final i = same ? lines.indexWhere((l) => l.kind != DiffKind.del && l.neu == d.line) : -1;
    if (i < 0) {
      left.add(d);
    } else {
      (at[i] ??= []).add(d);
    }
  }
  return (at: at, left: left);
}

/// The drafts the diff cannot show under a line: the summary, general
/// comments, those on a line outside the diff or on another commit, and published ones.
List<ReviewDraft> listedDrafts(List<ReviewDraft> drafts, List<FileChange> files, String headSha) {
  final lines = {
    for (final f in files) f.path: numberDiff(f.diff).where((l) => l.kind != DiffKind.del && l.neu != null).map((l) => l.neu!).toSet(),
  };
  return drafts
      .where(
        (x) =>
            x.kind == ReviewDraftKindEnum.summary ||
            x.path == null ||
            x.line == null ||
            (x.headSha.isNotEmpty && headSha.isNotEmpty && x.headSha != headSha) ||
            !(lines[x.path]?.contains(x.line) ?? false) ||
            x.state == ReviewDraftStateEnum.published,
      )
      .toList();
}

/// A line takes comments: added, removed, or unchanged context with a number.
bool lineCommentable(DiffLine l) => l.kind == DiffKind.add || l.kind == DiffKind.del || (l.kind == DiffKind.plain && l.neu != null);

/// The comment to post on a diff line: a removed line by its old number, an
/// added one by its new, an unchanged one by both (it is in both versions).
NewPullComment lineComment(DiffLine l, {required String body, required String path, String? headSha}) => switch (l.kind) {
  DiffKind.del => NewPullComment(body: body, path: path, headSha: headSha, oldLine: l.old),
  DiffKind.add => NewPullComment(body: body, path: path, headSha: headSha, line: l.neu),
  _ => NewPullComment(body: body, path: path, headSha: headSha, line: l.neu, oldLine: l.old),
};
