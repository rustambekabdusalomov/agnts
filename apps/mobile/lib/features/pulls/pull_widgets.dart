import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../ci/ci_screen.dart' show ciAgo;
import '../tickets/diff_highlight.dart';
import '../tickets/diff_lines.dart';
import '../tickets/kinds.dart' show ReportMarkdown;
import 'pulls_data.dart';

/// What a pull request's threads, drafts and diff can do; the pull request
/// screen carries it out and refreshes.
abstract class PullOps {
  bool get busy;
  bool get canEdit;

  /// "Posts as @login on GitHub", under every composer.
  String get postsAs;
  Future<void> reply(PullThread th);
  Future<void> edit(PullComment c);
  Future<void> delete(PullComment c);
  Future<void> resolve(PullThread th);
  Future<void> commentOnLine(FileChange f, DiffLine l);

  /// The review's drafts take decisions (a review, not locked, may edit).
  bool get draftsEditable;
  Future<void> setDraft(ReviewDraft d, UpdateReviewDraftRequestStateEnum state);
  Future<void> dismissDraft(ReviewDraft d);
  Future<void> editDraft(ReviewDraft d);
  Future<void> deleteDraft(ReviewDraft d);
}

/// What the composer sheet returns: the body, and whether it goes into the
/// review as a draft (the second button) instead of being posted now.
typedef Composed = ({String body, bool toReview});

/// A bottom sheet to write or edit a comment in Markdown. [alt] adds a
/// second way to send it (keep it as a draft of the review).
Future<Composed?> composeComment(
  BuildContext context, {
  String initial = '',
  required String action,
  String? as,
  String? alt,
  String? quote,
}) {
  final l = AppLocalizations.of(context);
  final text = TextEditingController(text: initial);
  return showModalBottomSheet<Composed>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final c = Agnts.of(ctx);
      void send(bool toReview) {
        final b = text.text.trim();
        if (b.isNotEmpty) Navigator.pop(ctx, (body: b, toReview: toReview));
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (quote != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  quote,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                ),
              ),
            TextField(
              controller: text,
              autofocus: true,
              minLines: 4,
              maxLines: 10,
              maxLength: 60000,
              decoration: InputDecoration(hintText: l.mpullsPlaceholder),
            ),
            if (as != null) Text(as, style: TextStyle(fontSize: 12.5, color: c.ink3)),
            const SizedBox(height: 10),
            Row(
              children: [
                if (alt != null) ...[
                  Expanded(
                    child: OutlinedButton(onPressed: () => send(true), child: Text(alt)),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: FilledButton(onPressed: () => send(false), child: Text(action)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

String verdictLabel(AppLocalizations l, String v) => switch (v) {
  'APPROVED' => l.pullsVerdict_APPROVED,
  'CHANGES_REQUESTED' => l.pullsVerdict_CHANGES_REQUESTED,
  'DISMISSED' => l.pullsVerdict_DISMISSED,
  _ => l.pullsVerdict_COMMENTED,
};

String pullStateLabel(AppLocalizations l, String s) => switch (s) {
  'open' => l.pullsState_open,
  'merged' => l.pullsState_merged,
  'closed' => l.pullsState_closed,
  _ => l.pullsState_all,
};

Tone pullStateTone(PullItemStateEnum s) => switch (s) {
  PullItemStateEnum.open => Tone.info,
  PullItemStateEnum.merged => Tone.ok,
  PullItemStateEnum.closed => Tone.gray,
};

/// Why the pull request is on agnts's list ("review requested").
String? whyLabel(AppLocalizations l, String why) => switch (why) {
  'assigned' => l.reviewsWhy_assigned,
  'review_requested' => l.reviewsWhy_review_requested,
  'open' => l.reviewsWhy_open,
  'own' => l.reviewsWhy_own,
  'manual' => l.reviewsWhy_manual,
  _ => null,
};

/// One thread of a pull request: its comments, with edit and delete on your
/// own, reply and resolve. [where] shows the file and line (off when the
/// thread sits in the diff already).
class PullThreadCard extends StatelessWidget {
  const PullThreadCard({super.key, required this.thread, required this.ops, this.where = true});
  final PullThread thread;
  final PullOps ops;
  final bool where;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final th = thread;
    final line = th.line ?? th.oldLine;
    final verdict = th.kind == PullThreadKindEnum.review ? th.reviewState : null;
    final hunk = (th.diffHunk ?? '').split('\n').where((x) => x.isNotEmpty).toList();
    final busy = ops.busy;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: th.resolved ? c.bg : c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (where && th.kind == PullThreadKindEnum.inline) ...[
            Wrap(
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
            if (hunk.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 6, bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(color: c.code, borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    hunk.skip(math.max(0, hunk.length - 4)).join('\n'),
                    softWrap: false,
                    style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 11.5, height: 1.5, color: c.codeInk),
                  ),
                ),
              )
            else
              const SizedBox(height: 6),
          ] else if (th.resolved) ...[
            ToneBadge(l.pullsResolved, Tone.ok, small: true),
            const SizedBox(height: 6),
          ],
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
                        Text(
                          cm.author,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: c.ink),
                        ),
                        if (i == 0 && verdict != null)
                          ToneBadge(
                            verdictLabel(l, verdict),
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
                    if (ops.canEdit && cm.mine)
                      Wrap(
                        children: [
                          TextButton(onPressed: busy ? null : () => ops.edit(cm), child: Text(l.pullsEdit)),
                          if (!cm.id.startsWith('rv:'))
                            TextButton(
                              onPressed: busy ? null : () => ops.delete(cm),
                              child: Text(l.pullsDelete, style: TextStyle(color: c.badInk)),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
          if (ops.canEdit)
            Wrap(
              children: [
                TextButton(onPressed: busy ? null : () => ops.reply(th), child: Text(l.pullsReply)),
                if (th.resolvable)
                  TextButton(onPressed: busy ? null : () => ops.resolve(th), child: Text(th.resolved ? l.pullsUnresolve : l.pullsResolve)),
              ],
            ),
        ],
      ),
    );
  }
}

/// One comment of agnts's review kept in agnts: a draft until a person
/// accepts it; only accepted ones are published on the git host.
class DraftCard extends StatelessWidget {
  const DraftCard({super.key, required this.draft, required this.ops, this.where = true});
  final ReviewDraft draft;
  final PullOps ops;
  final bool where;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final d = draft;
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
    final live = ops.draftsEditable && d.state != ReviewDraftStateEnum.publishing && d.state != ReviewDraftStateEnum.published;
    final dim = d.state == ReviewDraftStateEnum.dismissed || d.state == ReviewDraftStateEnum.outdated;
    final busy = ops.busy;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: d.state == ReviewDraftStateEnum.accepted ? c.okInk : c.line3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: dim ? 0.75 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ToneBadge(l.draftsChip, Tone.info, small: true),
                Text(
                  d.kind == ReviewDraftKindEnum.comment ? (d.author ?? l.draftsSomeone) : 'agnts',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: c.ink),
                ),
                if (d.kind == ReviewDraftKindEnum.finding && d.severity != null) ToneBadge(d.severity!, sevTone, small: true),
                if (d.kind == ReviewDraftKindEnum.summary) ToneBadge(l.draftsSummary, Tone.gray, small: true),
                if (d.kind == ReviewDraftKindEnum.finding && (d.category ?? '').isNotEmpty)
                  Text(d.category!, style: TextStyle(fontSize: 12.5, color: c.ink3)),
                ToneBadge(stateText, tone, small: true),
                if (d.edited) Text('· ${l.draftsEdited}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
                if (where && d.path != null)
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
            if (live)
              Wrap(
                children: [
                  if (d.state == ReviewDraftStateEnum.draft) ...[
                    TextButton(
                      onPressed: busy ? null : () => ops.setDraft(d, UpdateReviewDraftRequestStateEnum.accepted),
                      child: Text(l.draftsAccept),
                    ),
                    TextButton(onPressed: busy ? null : () => ops.editDraft(d), child: Text(l.pullsEdit)),
                    if (d.kind != ReviewDraftKindEnum.comment)
                      TextButton(onPressed: busy ? null : () => ops.dismissDraft(d), child: Text(l.draftsDismiss)),
                  ] else if (d.state == ReviewDraftStateEnum.accepted) ...[
                    TextButton(
                      onPressed: busy ? null : () => ops.setDraft(d, UpdateReviewDraftRequestStateEnum.draft),
                      child: Text(l.draftsUndo),
                    ),
                    TextButton(onPressed: busy ? null : () => ops.editDraft(d), child: Text(l.pullsEdit)),
                  ] else if (dim)
                    TextButton(
                      onPressed: busy ? null : () => ops.setDraft(d, UpdateReviewDraftRequestStateEnum.draft),
                      child: Text(l.draftsReopen),
                    ),
                  if (d.kind == ReviewDraftKindEnum.comment)
                    TextButton(
                      onPressed: busy ? null : () => ops.deleteDraft(d),
                      child: Text(l.pullsDelete, style: TextStyle(color: c.badInk)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

const _codeAdd = Color(0x382EA067); // rgba(46,160,103,.22)
const _codeDel = Color(0x3DD64034); // rgba(214,64,52,.24)
const _codeHunk = Color(0x2E7D96EB); // rgba(125,150,235,.18)
const _hunkInk = Color(0xFFB9C6F5);

/// The diff shows this many lines until asked for the rest.
const _firstLines = 400;

/// One changed file of a pull request, folded, with its review threads (and
/// the review's drafts) under their lines. Tapping a line comments on it.
class PullDiffFile extends StatefulWidget {
  const PullDiffFile({super.key, required this.file, required this.threads, required this.ops, this.drafts, this.headSha});
  final FileChange file;
  final List<PullThread> threads;
  final PullOps ops;
  final List<ReviewDraft>? drafts;
  final String? headSha;

  @override
  State<PullDiffFile> createState() => _PullDiffFileState();
}

class _PullDiffFileState extends State<PullDiffFile> {
  late bool _open = widget.threads.isNotEmpty || (widget.drafts?.isNotEmpty ?? false);
  bool _all = false;
  List<DiffLine> _lines = const [];
  List<List<CodeSpan>?>? _spans;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PullDiffFile old) {
    super.didUpdateWidget(old);
    if (old.file.diff != widget.file.diff || old.file.path != widget.file.path) _load();
  }

  Future<void> _load() async {
    final lines = _lines = numberDiff(widget.file.diff);
    _spans = null;
    if (widget.file.diff.isEmpty || languageFor(widget.file.path) == null) return;
    try {
      final spans = await compute(highlightDiff, (lines: lines, path: widget.file.path));
      if (mounted && identical(lines, _lines)) setState(() => _spans = spans);
    } catch (_) {
      // highlighting is a nicety; plain text still works
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final f = widget.file;
    final drafts = widget.drafts;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      f.path,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (drafts != null && drafts.isNotEmpty) ...[
                    ToneBadge(l.draftsDraftsN(drafts.length), Tone.info, small: true),
                    const SizedBox(width: 6),
                  ],
                  if (widget.threads.isNotEmpty) ...[
                    ToneBadge(l.pullsThreadsN(widget.threads.length), Tone.gray, small: true),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    '+${f.add}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.okInk),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '−${f.del}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.badInk),
                  ),
                ],
              ),
            ),
          ),
          if (_open) ..._body(context),
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final f = widget.file;
    final ops = widget.ops;
    final placed = placeThreads(_lines, widget.threads);
    final drafts = widget.drafts;
    final dPlaced = drafts == null ? null : placeDrafts(_lines, drafts, widget.headSha);
    Widget pad(Widget w) => Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 0), child: w);
    final out = <Widget>[];
    if (placed.left.isNotEmpty) {
      out.add(pad(Text(l.pullsEarlierVersion, style: TextStyle(fontSize: 13, color: c.ink3))));
      out.add(const SizedBox(height: 6));
      for (final th in placed.left) {
        out.add(pad(PullThreadCard(thread: th, ops: ops)));
      }
    }
    if (dPlaced != null && dPlaced.left.isNotEmpty) {
      out.add(pad(Text(l.draftsNotOnDiff, style: TextStyle(fontSize: 13, color: c.ink3))));
      out.add(const SizedBox(height: 6));
      for (final d in dPlaced.left) {
        out.add(pad(DraftCard(draft: d, ops: ops)));
      }
    }
    if (f.diff.isEmpty) {
      out.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Text(l.pullsNoPatch, style: TextStyle(fontSize: 13, color: c.ink3)),
        ),
      );
      return out;
    }
    if (ops.canEdit) {
      out.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Text(l.mpullsLineHint, style: TextStyle(fontSize: 12.5, color: c.ink3)),
        ),
      );
    }
    // The diff in runs of lines, with the threads and drafts of a line
    // between runs, right under it.
    final shown = _all ? _lines.length : math.min(_lines.length, _firstLines);
    var start = 0;
    for (var i = 0; i < shown; i++) {
      final ths = placed.at[i];
      final ds = dPlaced?.at[i];
      if (ths == null && ds == null) continue;
      out.add(_run(context, start, i + 1));
      start = i + 1;
      out.add(
        Container(
          color: c.bg,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final th in ths ?? const <PullThread>[]) PullThreadCard(thread: th, ops: ops, where: false),
              for (final d in ds ?? const <ReviewDraft>[]) DraftCard(draft: d, ops: ops, where: false),
            ],
          ),
        ),
      );
    }
    if (start < shown) out.add(_run(context, start, shown));
    if (shown < _lines.length) {
      out.add(TextButton(onPressed: () => setState(() => _all = true), child: Text(l.ticketShowMore)));
    }
    return out;
  }

  static Color? _bg(DiffKind k) => switch (k) {
    DiffKind.add => _codeAdd,
    DiffKind.del => _codeDel,
    DiffKind.hunk => _codeHunk,
    DiffKind.plain => null,
  };

  /// Lines [from, to) of the diff: line numbers stay put while long lines scroll sideways.
  Widget _run(BuildContext context, int from, int to) {
    final c = Agnts.of(context);
    const style = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 11.5, height: 1.6);
    final lines = _lines;
    final digits = lines.fold(2, (w, l) => math.max(w, '${l.old ?? l.neu ?? ''}'.length));
    final numStyle = style.copyWith(color: c.codeDim);
    final tp = TextPainter(
      text: TextSpan(text: '0' * digits, style: numStyle),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final numWidth = tp.width;
    tp.dispose();
    Widget num(int? n) => SizedBox(
      width: numWidth.ceilToDouble() + 1,
      child: Text(n?.toString() ?? '', textAlign: TextAlign.right, softWrap: false, style: numStyle),
    );
    final ops = widget.ops;
    void Function()? tap(DiffLine l) => ops.canEdit && !ops.busy && lineCommentable(l) ? () => ops.commentOnLine(widget.file, l) : null;
    return Container(
      color: c.code,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: const Color(0xFF7F7F7F).withValues(alpha: 0.25))),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = from; i < to; i++)
                    GestureDetector(
                      onTap: tap(lines[i]),
                      child: Container(
                        color: _bg(lines[i].kind),
                        padding: const EdgeInsets.only(left: 4, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [num(lines[i].old), const SizedBox(width: 6), num(lines[i].neu)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: box.maxWidth),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = from; i < to; i++)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: tap(lines[i]),
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, right: 14),
                              color: _bg(lines[i].kind),
                              child: switch (_spans != null && i < _spans!.length ? _spans![i] : null) {
                                final spans? => Text.rich(
                                  TextSpan(
                                    text: lines[i].text[0],
                                    children: [for (final sp in spans) TextSpan(text: sp.text, style: styleFor(sp.scope))],
                                  ),
                                  softWrap: false,
                                  style: style.copyWith(color: c.codeInk),
                                ),
                                null => Text(
                                  lines[i].text,
                                  softWrap: false,
                                  style: style.copyWith(color: lines[i].kind == DiffKind.hunk ? _hunkInk : c.codeInk),
                                ),
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
