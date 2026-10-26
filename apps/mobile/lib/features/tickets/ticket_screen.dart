
import 'dart:async';

import 'package:dio/dio.dart' show DioException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../ci/ci_card.dart';
import '../documents/ticket_documents.dart';
import '../learn/ticket_lessons.dart';
import 'api_results.dart';
import 'code_review.dart';
import 'file_diff.dart';
import 'follow_ups.dart';
import 'harness.dart';
import 'kinds.dart';
import 'linked_commits.dart';
import 'preview_shots.dart';
import 'pull_comments.dart';
import 'commit_messages.dart';
import 'commit_reapply.dart';
import 'relations.dart';
import 'repo_diffs.dart';
import 'spend.dart';
import 'ticket_controls.dart';
import 'ticket_repos.dart';
import 'ticket_section.dart';
import 'translation.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/attachments.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../../widgets/workspace.dart';
import '../account/account_widgets.dart' show openLink;

/// One ticket (scrDetail in mobile.html): header, the six-stop progress
/// track, a block for the current state, folds for answers and history, and
/// a sticky action bar with whatever the ticket needs from you.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, required this.ticketKey});
  final String ticketKey;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  // Per question: the picked option pill (the picked set for a multiple-
  // choice question), the details / own answer text, and attached files.
  final Map<int, String?> _picked = {};
  final Map<int, Set<String>> _chosen = {};
  final Map<int, TextEditingController> _notes = {};
  final Map<int, AttachmentsController> _answerFiles = {};
  // Unsent answers are saved as they are typed (see _saveDrafts), so
  // closing the app loses nothing; they come back on any device. Each
  // question's draft as last sent, the questions being answered now, and
  // the API to save with (kept for dispose, when ref is gone).
  final Map<int, String> _savedDraft = {};
  List<Question> _answering = const [];
  TicketsApi? _draftApi;
  Timer? _draftTimer;
  _DraftState? _draftState;
  late final _lifecycle = AppLifecycleListener(onHide: _flushDrafts);
  // Set in dispose, whose last save must not rebuild.
  bool _gone = false;
  // A failed run's retry note and its files.
  final _retryNote = TextEditingController();
  late final _retryFiles = AttachmentsController()..addListener(_filesChanged);
  // What to do differently when a rejected ticket is continued, and files.
  final _continueNote = TextEditingController();
  late final _continueFiles = AttachmentsController()..addListener(_filesChanged);
  final _feedback = TextEditingController();
  // Preview screenshots the feedback points at.
  final _feedbackShots = ValueNotifier<List<FeedbackShot>>(const []);
  // Files that go with the feedback.
  final _feedbackFiles = AttachmentsController();
  bool _busy = false;
  bool _descOpen = false;
  // Reports reach the tracker issue only when the reviewer ticks this.
  bool _postReport = false;
  // Whether coding runs skip the checks, as ticked on the retry or the
  // request-changes form; null: the ticket's own setting, left as it is.
  bool? _skipChecks;
  // Assignees of the pull request agnts opens on approval, for the
  // ticket and state they were picked in.
  final Set<String> _assignees = {};
  String _assigneesFor = '';
  // The ticket's texts in the language it is read in.
  Tr _tr = _asWritten;

  static String _asWritten(String s) => s;

  /// Starts the assignees from the ticket's when it opens or changes state.
  void _syncAssignees(Ticket t) {
    final at = '${t.key}@${t.state.name}';
    if (at == _assigneesFor) return;
    _assigneesFor = at;
    _assignees
      ..clear()
      ..addAll(t.assignees ?? const []);
  }

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _gone = true;
    _flushDrafts();
    _lifecycle.dispose();
    for (final c in _notes.values) {
      c.dispose();
    }
    for (final c in _answerFiles.values) {
      c.dispose();
    }
    _retryNote.dispose();
    _retryFiles.dispose();
    _continueNote.dispose();
    _continueFiles.dispose();
    _feedback.dispose();
    _feedbackShots.dispose();
    _feedbackFiles.dispose();
    super.dispose();
  }

  /// The submit buttons follow the uploads.
  void _filesChanged() {
    if (mounted) setState(() {});
  }

  AttachmentsController _filesFor(Question q) => _answerFiles.putIfAbsent(
      q.id,
      () => AttachmentsController()
        ..addListener(_filesChanged)
        ..addListener(_draftChanged));

  /// The question's text field, started from its unsent draft when it has
  /// no answer yet, else from its answer.
  TextEditingController _noteFor(Question q) {
    final have = _notes[q.id];
    if (have != null) return have;
    final draft = q.answer == null ? q.draft : null;
    if (draft != null && draft.attachments.isNotEmpty) _filesFor(q).restore(draft.attachments);
    final a = draft?.answer ?? q.answer;
    final note = draft?.note ?? q.note;
    // A draft made on the web keeps its details apart even where this
    // screen has one field for both: they go after the text, not lost.
    final draftNote = draft != null && draft.note.trim().isNotEmpty ? draft.note.trim() : null;
    final TextEditingController c;
    if (q.multiple) {
      // One option per line; lines that are not options are the own text.
      final lines = (a ?? '').split('\n').where((x) => x.trim().isNotEmpty).toList();
      _chosen[q.id] = {for (final x in lines) if (q.options.contains(x)) x};
      c = TextEditingController(text: [...lines.where((x) => !q.options.contains(x)), ?draftNote].join('\n'));
    } else if (a != null && q.options.contains(a)) {
      _picked[q.id] = a;
      c = TextEditingController(text: note);
    } else {
      c = TextEditingController(text: [if (a != null && a.trim().isNotEmpty) a, ?draftNote].join('\n'));
    }
    _notes[q.id] = c;
    _savedDraft[q.id] = _draftKey(q);
    return c..addListener(_draftChanged);
  }

  /// The question's uploads, without making a picker for it: dispose
  /// reads them too.
  List<int> _fileIds(Question q) => _answerFiles[q.id]?.ids ?? const [];

  String _draftKey(Question q) => [_answerOf(q), _noteOf(q) ?? '', _fileIds(q).join(',')].join('\u0000');

  /// Saves the drafts a moment after the typing stops.
  void _draftChanged() {
    if (_answering.isEmpty || _busy) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 800), _flushDrafts);
  }

  void _flushDrafts() {
    _draftTimer?.cancel();
    _draftTimer = null;
    _saveDrafts(widget.ticketKey, _answering);
  }

  /// Sends the drafts of the questions changed since the last save. The
  /// request is built before the first await: dispose may follow at once.
  Future<void> _saveDrafts(String key, List<Question> qs) async {
    final api = _draftApi;
    final changed = [for (final q in qs) if (_notes.containsKey(q.id) && _draftKey(q) != _savedDraft[q.id]) q];
    if (api == null || changed.isEmpty) return;
    final sent = {for (final q in changed) q.id: _draftKey(q)};
    final req = AnswerDraftRequest(answers: [
      for (final q in changed)
        AnswerDraftRequestAnswersInner(
          questionId: q.id,
          answer: _answerOf(q),
          note: _noteOf(q),
          attachments: _fileIds(q).isEmpty ? null : _fileIds(q),
        ),
    ]);
    _savedDraft.addAll(sent);
    _setDraftState(_DraftState.saving);
    try {
      await api.saveAnswerDraft(key: key, answerDraftRequest: req);
      if (_draftState == _DraftState.saving) _setDraftState(_DraftState.saved);
    } catch (e) {
      sent.forEach((id, k) {
        if (_savedDraft[id] == k) _savedDraft.remove(id);
      });
      // 409: the questions are answered or gone; nothing to keep.
      if (e is DioException && e.response?.statusCode == 409) return _setDraftState(null);
      _setDraftState(_DraftState.failed);
      if (!_gone) _draftTimer ??= Timer(const Duration(seconds: 5), _flushDrafts);
    }
  }

  void _setDraftState(_DraftState? s) {
    _draftState = s;
    if (mounted && !_gone) setState(() {});
  }

  /// The answer sent for [q]: the picked option, else the typed text. For a
  /// multiple-choice question: the picked options in their order, then the
  /// typed text, one per line.
  String _answerOf(Question q) {
    final note = _noteFor(q).text.trim();
    if (q.multiple) {
      final chosen = _chosen[q.id] ?? const {};
      return [for (final o in q.options) if (chosen.contains(o)) o, if (note.isNotEmpty) note].join('\n');
    }
    return _picked[q.id] ?? note;
  }

  /// The questions as plain text, to paste into a chat for whoever can answer.
  /// "Q1.", not "1.": chat editors read "1." as a list and restart it at 1
  /// after each question's options.
  String _questionsText(Ticket t, List<Question> qs, AppLocalizations l) => [
        '${t.key}: ${_tr(t.title)}',
        '',
        for (final (i, q) in qs.indexed) ...[
          'Q${i + 1}. ${_tr(q.text)}${q.multiple ? ' (${l.ticketPickAny})' : ''}',
          for (final o in q.options) '   - ${_tr(o)}',
        ],
      ].join('\n');

  /// The details sent with a picked option (null when the text is the answer).
  String? _noteOf(Question q) {
    if (q.multiple) return null;
    final note = _noteFor(q).text.trim();
    return _picked[q.id] != null && note.isNotEmpty ? note : null;
  }

  void _toggle(Question q, String o) => setState(() {
        if (q.multiple) {
          final chosen = _chosen.putIfAbsent(q.id, () => {});
          if (!chosen.remove(o)) chosen.add(o);
        } else {
          _picked[q.id] = _picked[q.id] == o ? null : o;
        }
        _draftChanged();
      });

  /// Retries a stopped run, with the note and files when it can take them.
  Future<void> _retry(Ticket t) async {
    final note = _retryNote.text.trim();
    final ids = _retryFiles.ids;
    final extra = _takesRetryNote(t) && (note.isNotEmpty || ids.isNotEmpty);
    final skip = _takesRetryNote(t) ? _skipChecks : null;
    final ok = await _run(() => _tickets.retryTicket(
          key: t.key,
          retryTicketRequest: extra || skip != null
              ? RetryTicketRequest(note: extra && note.isNotEmpty ? note : null, attachments: extra && ids.isNotEmpty ? ids : null, skipChecks: skip)
              : null,
        ));
    if (!ok) return;
    _retryNote.clear();
    _retryFiles.clear();
    _skipChecks = null;
  }

  /// Picks a rejected ticket up again, with the note and files when its
  /// next stage runs Claude.
  Future<void> _continue(Ticket t) async {
    final note = _continueNote.text.trim();
    final ids = _continueFiles.ids;
    final extra = _takesContinueNote(t) && (note.isNotEmpty || ids.isNotEmpty);
    final ok = await _run(() => _tickets.continueTicket(
          key: t.key,
          continueTicketRequest: extra ? ContinueTicketRequest(note: note.isEmpty ? null : note, attachments: ids.isEmpty ? null : ids) : null,
        ));
    if (!ok) return;
    _continueNote.clear();
    _continueFiles.clear();
  }

  bool _canRename(TicketRepoState? r) => r?.canRenameBranch == true && ref.watch(canEditProvider);

  /// Renames a branch agnts has not pushed yet: the pull request opens
  /// from the new name.
  Future<void> _renameBranch(String key, TicketRepoState r) async {
    final l = AppLocalizations.of(context);
    final text = TextEditingController(text: r.branch);
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: text,
            autofocus: true,
            maxLength: 200,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 14),
            decoration: InputDecoration(labelText: l.ticketBranch),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
          Text(l.ticketBranchRenameHint, style: TextStyle(fontSize: 12.5, color: Agnts.of(ctx).ink3)),
          const SizedBox(height: 10),
          FilledButton(onPressed: () => Navigator.pop(ctx, text.text.trim()), child: Text(l.formSave)),
        ]),
      ),
    );
    text.dispose();
    if (name == null || name.isEmpty || name == r.branch) return;
    await _run(() => _tickets.renameTicketBranch(
          key: key,
          renameTicketBranchRequest: RenameTicketBranchRequest(branch: name, repoId: r.repoId),
        ));
  }

  /// Changes the team's number for the work ({number} in branch and commit
  /// names), until the ticket is done or rejected; empty uses the key.
  Future<void> _setNumber(Ticket t) async {
    final l = AppLocalizations.of(context);
    final text = TextEditingController(text: t.ticketNumber ?? '');
    final number = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            controller: text,
            autofocus: true,
            maxLength: 64,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 14),
            decoration: InputDecoration(labelText: l.tasksTicketNumber, hintText: t.key),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
          Text(l.ticketNumberHint, style: TextStyle(fontSize: 12.5, color: Agnts.of(ctx).ink3)),
          const SizedBox(height: 10),
          FilledButton(onPressed: () => Navigator.pop(ctx, text.text.trim()), child: Text(l.formSave)),
        ]),
      ),
    );
    text.dispose();
    if (number == null || number == (t.ticketNumber ?? '')) return;
    await _run(() => _tickets.setTicketNumber(key: t.key, setTicketNumberRequest: SetTicketNumberRequest(number: number)));
  }

  /// Re-applies the commit format to the unpushed commits: a preview with
  /// checkboxes first (see CommitReapplySheet), then the ticked changes.
  Future<void> _reapplyFormat(Ticket t) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CommitReapplySheet(
        ticket: t,
        call: (number, dryRun, only) async {
          final res = await _tickets.reapplyCommitFormat(
            key: t.key,
            reapplyCommitFormatRequest: ReapplyCommitFormatRequest(number: number, dryRun: dryRun, only: only),
          );
          return res.data?.changes ?? const [];
        },
      ),
    );
    if (done == true) {
      ref.invalidate(ticketProvider(widget.ticketKey));
      ref.invalidate(dashboardProvider);
    }
  }

  /// Changes the message of one of agnts's commits before it pushes them.
  Future<void> _editCommit(Ticket t, TicketRepoState r, BranchCommit commit) async {
    final l = AppLocalizations.of(context);
    final text = TextEditingController(text: commit.message);
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.ticketCommitEdit, style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 10),
          TextField(
            controller: text,
            autofocus: true,
            minLines: 4,
            maxLines: 10,
            inputFormatters: [LengthLimitingTextInputFormatter(10000)],
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13.5, height: 1.4),
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11)),
          ),
          const SizedBox(height: 6),
          Text(l.ticketCommitEditHint, style: TextStyle(fontSize: 12.5, color: Agnts.of(ctx).ink3)),
          const SizedBox(height: 10),
          FilledButton(onPressed: () => Navigator.pop(ctx, text.text), child: Text(l.formSave)),
        ]),
      ),
    );
    text.dispose();
    if (message == null || message.trim().isEmpty || message.trim() == commit.message.trim()) return;
    await _run(() => _tickets.editCommitMessage(
          key: t.key,
          editCommitMessageRequest: EditCommitMessageRequest(sha: commit.sha, message: message, repoId: isMultiRepo(t) ? r.repoId : null),
        ));
  }

  Future<void> _startOver(BuildContext context, String key) async {
    final l = AppLocalizations.of(context);
    if (await _confirm(l.ticketStartOverConfirm(key))) await _run(() => _tickets.startTicketOver(key: key));
  }

  TicketsApi get _tickets => ref.read(apiProvider)!.getTicketsApi();

  /// Runs [action], then refreshes the ticket; false when it failed.
  Future<bool> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(ticketProvider(widget.ticketKey));
      ref.invalidate(dashboardProvider);
      return true;
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.ticketConflict));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// agnts's code review card; queues a (re-)review like the other actions.
  Widget _codeReview(TicketDetail d) => CodeReviewCard(
        detail: d,
        feedback: _feedback,
        busy: _busy,
        onRun: () => _run(() => _tickets.reviewTicket(key: d.ticket.key)),
        onFollowUp: (i) => _run(() async {
          await _tickets.followUpFromFinding(key: d.ticket.key, index: i);
          if (mounted) showSnack(context, AppLocalizations.of(context).followUpsFromFindingDone);
        }),
      );

  /// agnts's preview card (screenshots of the running app), for tickets
  /// whose repository can be previewed or that already have a preview.
  Widget _preview(TicketDetail d) {
    final t = d.ticket;
    final state = t.previewState ?? TicketPreviewStateEnum.none;
    if (d.preview == null && t.canPreview != true && state == TicketPreviewStateEnum.none) return const SizedBox.shrink();
    return PreviewCard(
      detail: d,
      feedback: _feedback,
      shots: _feedbackShots,
      busy: _busy,
      onRun: (compare) => _run(() => _tickets.previewTicket(key: t.key, previewInput: PreviewInput(compare: compare))),
    );
  }

  Future<bool> _confirm(String text) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.mobileConfirm)),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final detail = ref.watch(ticketProvider(widget.ticketKey));
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: detail.value == null ? widget.ticketKey : ticketNo(detail.value!.ticket),
        onBack: () => context.canPop() ? context.pop() : context.go('/tickets'),
        actions: [if (detail.value != null) TranslateButton(widget.ticketKey)],
      ),
      body: AsyncBody<TicketDetail>(
        value: detail,
        onRefresh: () async {
          ref.invalidate(ticketEventsProvider(widget.ticketKey));
          ref.invalidate(ticketProvider(widget.ticketKey));
          ref.invalidate(ticketCIProvider(widget.ticketKey));
          await ref.read(ticketProvider(widget.ticketKey).future);
        },
        builder: (d) {
          final translation = watchTranslation(ref, d.ticket);
          _tr = translation.tr;
          _syncAssignees(d.ticket);
          final t = d.ticket;
          final answering = t.state == TicketState.waitingForAnswers && ref.watch(canEditProvider);
          _answering = answering ? d.questions : const [];
          _draftApi = answering ? ref.read(apiProvider)?.getTicketsApi() : null;
          return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _header(context, d),
            TranslationStatus(translation.state),
            if (t.replayOf != null && t.replayOf!.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: ReplayBanner(t.replayOf!)),
            if (t.trackerUpdate != null) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: TrackerUpdateCard(t)),
            TicketCICard(d.ticket),
            if (d.ticket.waitReason != null) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: WaitBanner(d.ticket)),
            _Track(ticket: d.ticket, history: d.history ?? const []),
            // A viewer reads the stage (questions, the result to review) but cannot act on it.
            IgnorePointer(ignoring: !ref.watch(canEditProvider), child: _stage(context, d)),
            _folds(context, d),
          ],
        );
        },
      ),
      bottomNavigationBar: detail.value == null || !ref.watch(canEditProvider) ? null : _actionBar(context, detail.value!),
    );
  }

  // ---- Header (.d-head) ----

  Widget _header(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final isTask = t.source_ == TicketSource_Enum.local;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 13, color: c.ink3),
          child: Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            StateBadge(t.state, kind: t.kind),
            SourceChip(sourceLabel(l, t.source_), task: isTask),
            KindChip(t),
            if (t.repoName != null && t.repoName!.isNotEmpty) Text(repoLabel(t)!),
            if (t.group != null) Text(l.mgroupsGroup(t.group!.name)),
            if (t.partlyMerged == true) ToneBadge(l.mgroupsPartlyMerged, Tone.warn, small: true),
            if (t.priority.isNotEmpty) Text(t.priority),
            if (t.revision > 0) Text(l.ticketRevision(t.revision.toString())),
          ]),
        ),
        const SizedBox(height: 8),
        Text(_tr(t.title), style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.15)),
        if (t.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _descOpen = !_descOpen),
            child: Text(
              _tr(t.description),
              maxLines: _descOpen ? null : 6,
              overflow: _descOpen ? null : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: c.ink2, height: 1.45),
            ),
          ),
        ],
        TicketMemberRow(t),
        AttachmentList(d.attachments.where((a) => a.purpose == AttachmentPurposeEnum.ticket).toList()),
        // A multi-repo ticket lists each repository's branch and pull request.
        TicketRepos(t, onRename: _canRename(t.repos?.firstOrNull) ? (r) => _renameBranch(t.key, r) : null),
        if (t.branch.isNotEmpty && !isMultiRepo(t))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              Expanded(child: Text('${l.ticketBranch}: ${t.branch}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3))),
              if (_canRename(t.repos?.firstOrNull))
                TextButton(
                  onPressed: _busy ? null : () => _renameBranch(t.key, t.repos!.first),
                  child: Text(l.ticketBranchRename),
                ),
            ]),
          ),
        if (t.source_ != TicketSource_Enum.git)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Expanded(
                child: Text('${l.tasksTicketNumber}: ${ticketNo(t)}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3)),
              ),
              if (ref.watch(canEditProvider) && t.state != TicketState.done && t.state != TicketState.rejected)
                TextButton(
                  onPressed: _busy ? null : () => _setNumber(t),
                  child: Text(t.ticketNumber == null ? l.ticketNumberSet : l.ticketNumberEdit),
                ),
            ]),
          ),
        if (t.prUrl.isNotEmpty && !isMultiRepo(t))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SelectableText(t.prUrl, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.primary)),
          ),
        if (t.parentKey != null && t.parentKey!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => context.push('/tickets/${t.parentKey}'),
              child: Text('${l.implementImplements} ${t.parentKey}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
            ),
          ),
        if (t.followUpOf != null && t.followUpOf!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => context.push('/tickets/${t.followUpOf}'),
              child: Text('${l.followUpsFollowUpOf} ${t.followUpOf}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
            ),
          ),
      ]),
    );
  }

  // ---- The state's block (dStage) ----

  Widget _stage(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final report = isReportKind(t.kind);
    final pull = isPullReview(t);
    String rev(String title) => t.revision > 0 ? l.ticketRevisionSuffix(title, t.revision.toString()) : title;
    final children = <Widget>[];
    switch (t.state) {
      case TicketState.new_:
        children.addAll([
          _H2(l.ticketQueuedTitle),
          _Sub(t.held == true ? l.ticketHeldSub : (report ? l.ticketQueuedSubReport : l.ticketQueuedSub)),
          KindPicker(t),
          if (!pull) ...[RepoPicker(t), ModelPicker(t, stages: const [ModelStage.analyze, ModelStage.coding])],
        ]);
      case TicketState.analyzing:
        children.addAll([
          _H2(t.repoId == null ? l.ticketAnalyzingTitleNoRepo : l.ticketAnalyzingTitle),
          _Sub(t.repoId == null ? l.ticketAnalyzingSubNoRepo : l.ticketAnalyzingSub(t.repoName ?? '')),
          TicketSection(id: 'log', title: l.ticketLog, children: [_liveLog(context, true)]),
        ]);
      case TicketState.waitingForAnswers:
        children.addAll([
          _H2(l.ticketQuestionsTitle(d.questions.length)),
          _Sub(l.ticketQuestionsSub),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _questionsText(t, d.questions, l)));
                if (context.mounted) showSnack(context, l.formCopied);
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text(l.ticketCopyQuestions),
            ),
          ),
          if (d.analysis != null) _analysisFold(context, d.analysis!),
          DesignRecord(analysis: d.analysis, tr: _tr),
          for (final q in d.questions) _questionCard(context, q),
          KindPicker(t),
          ModelPicker(t, stages: const [ModelStage.coding, ModelStage.retry]),
        ]);
      case TicketState.coding when t.blockedBy?.isNotEmpty ?? false:
        children.addAll([
          _H2(l.relationsWaitingTitle),
          _Sub(l.relationsWaitingSub),
          const SizedBox(height: 8),
          WaitingBlock(t.blockedBy!.toList()),
        ]);
      case TicketState.coding:
      case TicketState.testing:
        children.addAll([
          _H2(rev(report ? l.ticketWritingTitle : t.state == TicketState.coding ? l.ticketCodingTitle : l.ticketTestingTitle)),
          _Sub(report ? l.ticketWritingSub : l.ticketCodingSub(t.branch)),
          const SizedBox(height: 8),
          _runFacts(context, d),
          TicketSection(id: 'log', title: l.ticketLog, children: [_liveLog(context, true)]),
        ]);
      case TicketState.waitingForReview when report:
        children.addAll([_H2(rev(l.ticketReviewReportTitle)), ..._reviewReport(context, d)]);
      case TicketState.waitingForReview:
        children.addAll([_H2(rev(l.ticketReviewTitle)), ..._review(context, d)]);
      case TicketState.pushing:
        children.addAll([
          _H2(report ? l.ticketDeliveringTitle : l.ticketPushingTitle),
          _Sub(report ? l.ticketDeliveringSub : l.ticketPushingSub),
          TicketSection(id: 'log', title: l.ticketLog, children: [_liveLog(context, true)]),
        ]);
      case TicketState.done when report:
        children.addAll([
          _H2(l.ticketDoneReportTitle),
          const SizedBox(height: 8),
          HelpBox(t.postReport == true ? l.ticketDoneReportPosted(t.key) : l.ticketDoneReport, tone: Tone.ok),
          if (t.kind == TicketKind.plan || t.kind == TicketKind.bug) ImplementReport(t, childKey: d.childKey),
          if (d.result?.report != null) TicketSection(id: 'report', title: l.ticketReport, children: [ReportMarkdown(_tr(d.result!.report!))]),
        ]);
      case TicketState.done:
        final toMain = t.afterApprove == TicketAfterApproveEnum.main && t.source_ == TicketSource_Enum.local;
        final text = toMain
            ? l.ticketDoneMain(t.repoName ?? '')
            : t.prNumber != null
                ? l.ticketDonePr(t.prNumber.toString(), t.branch)
                : l.ticketDoneTitle;
        children.add(HelpBox(text, tone: Tone.ok));
        if (t.mergedAt != null) {
          children.add(Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(l.ticketMergedAt(_when(context, t.mergedAt!)), style: TextStyle(fontSize: 14, color: c.ink3)),
          ));
        } else if (t.prUrl.isNotEmpty) {
          children.addAll([
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _busy ? null : () => _run(() => _tickets.markTicketMerged(key: t.key)),
              child: Text(l.relationsMarkMerged),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.relationsMarkMergedHint, style: TextStyle(fontSize: 13, color: c.ink3)),
            ),
          ]);
        }
        children.add(TicketLessons(t));
        if (!pull && (t.replayOf == null || t.replayOf!.isEmpty) && t.repoId != null) children.add(ReplayButton(t));
      case TicketState.rejected:
        final whereTo = _continueHint(l, t.continueTo);
        children.addAll([
          _H2(l.ticketRejectedTitle),
          _Sub(t.continueTo == null ? l.ticketRejectedSub : l.ticketRejectedSubContinue),
          if (_takesContinueNote(t)) ...[
            _H3(l.ticketContinueNote),
            TextField(
              controller: _continueNote,
              enabled: !_busy,
              minLines: 2,
              maxLines: 6,
              inputFormatters: [LengthLimitingTextInputFormatter(4000)],
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 16, height: 1.4),
              decoration: InputDecoration(
                hintText: l.ticketContinueNoteHint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
            ),
            const SizedBox(height: 10),
            AttachmentPicker(controller: _continueFiles, enabled: !_busy),
          ],
          if (whereTo != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(whereTo, style: TextStyle(fontSize: 13, color: c.ink3))),
        ]);
      case TicketState.failed:
        children.addAll([
          _H2(l.ticketFailedTitle),
          const SizedBox(height: 8),
          HelpBox(t.stopReason ?? l.ticketFailedUnknown, tone: Tone.bad, copyable: t.stopReason != null),
          if (kindEditable(t) && !pull) KindPicker(t),
          if (canChangeRepo(t) && !pull) RepoPicker(t),
          if (!pull) ModelPicker(t, stages: const [ModelStage.retry]),
          // A run that stopped while pushing resumes there: nothing to tell it.
          if (_takesRetryNote(t)) ...[
            _H3(l.ticketRetryNote),
            TextField(
              controller: _retryNote,
              enabled: !_busy,
              minLines: 2,
              maxLines: 6,
              inputFormatters: [LengthLimitingTextInputFormatter(4000)],
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 16, height: 1.4),
              decoration: InputDecoration(
                hintText: l.ticketRetryNoteHint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
            ),
            const SizedBox(height: 10),
            AttachmentPicker(controller: _retryFiles, enabled: !_busy),
            _skipChecksBox(t, onChanged: (v) => setState(() => _skipChecks = v)),
          ],
        ]);
      case TicketState.rateLimited:
        final u = ref.watch(usageProvider).value?.fiveHour.utilization;
        children.addAll([
          _H2(l.ticketRateTitle),
          if (t.stopReason != null) ...[const SizedBox(height: 8), HelpBox(t.stopReason!, tone: Tone.warn, copyable: true)],
          if (u != null) Padding(padding: const EdgeInsets.only(top: 10), child: _Sub(l.ticketRateHint('${(u * 100).round()}'))),
          if (canChangeRepo(t)) RepoPicker(t),
        ]);
    }
    if (t.stopReason != null && t.state != TicketState.failed && t.state != TicketState.rateLimited) {
      children.addAll([const SizedBox(height: 10), HelpBox(t.stopReason!, tone: Tone.gray, copyable: true)]);
    }
    final warning = _kindWarning(t);
    if (warning != null) children.insert(0, Padding(padding: const EdgeInsets.only(bottom: 12), child: warning));
    return _Block(children: children);
  }

  /// The analysis disagreed with a kind someone chose: say so, and offer
  /// the switch while the kind can still change.
  Widget? _kindWarning(Ticket t) {
    final l = AppLocalizations.of(context);
    final evs = ref.watch(ticketEventsProvider(widget.ticketKey)).value ?? const <Event>[];
    final ev = evs.where((e) => e.type == 'kind_changed').lastOrNull;
    if (ev == null || ev.level != EventLevelEnum.warn || ev.data['from'] != t.kind.name || ev.data['to'] == t.kind.name) return null;
    final to = TicketKindChoice.values.where((k) => k.name == ev.data['to']).firstOrNull;
    return HelpBox(
      ev.message,
      tone: Tone.warn,
      child: to == null || !kindEditable(t)
          ? null
          : Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: _busy ? null : () => _run(() => _tickets.setTicketKind(key: t.key, ticketKindInput: TicketKindInput(kind: to))),
                child: Text(l.kindSwitchTo(kindChoiceLabel(l, to))),
              ),
            ),
    );
  }

  /// A report under review: summary, notes, the report, and whether to post it.
  List<Widget> _reviewReport(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final r = d.result;
    final plane = t.source_ == TicketSource_Enum.plane;
    final tracked = plane || t.source_ == TicketSource_Enum.jira;
    return [
      _Sub(tracked ? (plane ? l.ticketReviewReportSubPlane : l.ticketReviewReportSubJira) : l.ticketReviewReportSub),
      if (r != null && r.summary.isNotEmpty) ...[const SizedBox(height: 8), Text(_tr(r.summary), style: const TextStyle(fontSize: 15, height: 1.45))],
      if (r != null && r.notes.isNotEmpty) TicketSection(id: 'notes', title: l.ticketNotes, hint: '${r.notes.length}', children: _noteList(r.notes)),
      ModelPicker(t, stages: const [ModelStage.retry, ModelStage.review]),
      _codeReview(d),
      TicketSection(id: 'report', title: l.ticketReport, children: [
        if (r?.report != null) ReportMarkdown(_tr(r!.report!)) else Text(l.ticketReportMissing, style: TextStyle(color: c.ink3)),
      ]),
      if (tracked)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CheckboxListTile(
            value: _postReport,
            onChanged: _busy ? null : (v) => setState(() => _postReport = v ?? false),
            title: Text(plane ? l.ticketPostReportPlane(t.key) : l.ticketPostReport(t.key), style: const TextStyle(fontSize: 15)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
    ];
  }

  /// Model, turns, turn limit and session usage of a running ticket (.facts).
  Widget _runFacts(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final t = d.ticket;
    final models = d.effectiveModels;
    final model = models == null ? null : (t.revision > 0 ? models.retry : models.coding);
    final u = ref.watch(usageProvider).value?.fiveHour.utilization;
    return Grid2(gap: 8, children: [
      if (model != null) Fact(l.ticketFactModel, _modelName(model)),
      Fact(l.ticketFactTurns, '${t.turns}'),
      if (d.maxTurns != null) Fact(l.ticketFactTurnLimit, '${d.maxTurns}'),
      if (u != null) Fact(l.ticketFactSession, '${(u * 100).round()}%'),
    ]);
  }

  List<Widget> _review(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final t = d.ticket;
    final toMain = t.afterApprove == TicketAfterApproveEnum.main && t.source_ == TicketSource_Enum.local;
    final sub = toMain
        ? l.ticketReviewSubMain
        : t.source_ == TicketSource_Enum.jira
            ? l.ticketReviewSubJira(t.branch)
            : t.source_ == TicketSource_Enum.plane
                ? l.ticketReviewSubPlane(t.branch)
                : l.ticketReviewSubPr(t.branch);
    final r = d.result;
    final pull = isPullReview(t);
    final controls = <Widget>[
      if (!pull) ...[
        DesignRecord(analysis: d.analysis, deviations: r?.deviations, tr: _tr),
        ModelPicker(t, stages: [ModelStage.retry, ModelStage.review, if (t.canPreview == true) ModelStage.preview]),
      ],
      if (opensPr(t) && t.repoId != null)
        AssigneePicker(
          repoId: t.repoId!,
          selected: _assignees,
          onToggle: (u) => setState(() => _assignees.contains(u) ? _assignees.remove(u) : _assignees.add(u)),
        ),
    ];
    final secrets = secretFlagCount(r);
    final checks = <Widget>[
      if (r?.redFlags?.isNotEmpty ?? false) RedFlagsList(r!.redFlags!),
      HarnessChecks(r),
      if (secrets > 0 && !pull) SecretsAck(ticket: t, count: secrets),
    ];
    if (r == null) return [_Sub(sub), _codeReview(d), _preview(d), ...controls];
    final passed = r.checks.where((x) => x.exitCode == 0).length;
    final allOk = passed == r.checks.length;
    final time = _reviewTime(d);
    return [
      _Sub(sub),
      const SizedBox(height: 8),
      Grid2(gap: 8, children: [
        if (t.skipChecks && r.checks.isEmpty)
          Fact(l.ticketFactTests, l.ticketChecksSkipped)
        else
          Fact(l.ticketFactTests, r.checks.isEmpty ? l.ticketNoChecks : l.ticketChecksPassed(passed),
              tone: r.checks.isEmpty ? null : (allOk ? Tone.ok : Tone.bad)),
        Fact(l.ticketFactChanged, _changed(l, r)),
        if (time != null) Fact(l.mdetailFactTime, shortDuration(time)),
        Fact(l.ticketFactTurns, '${t.turns}'),
      ]),
      ..._resultBody(context, r, checking: false),
      if (hasEditableCommits(t))
        TicketSection(id: 'commits', title: l.ticketCommitsTitle, hint: '${commitCount(t)}', children: [
          _Sub(l.ticketCommitsSub),
          if (ref.watch(canEditProvider))
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: _busy ? null : () => _reapplyFormat(t), child: Text(l.ticketCommitsReapply)),
            ),
          const SizedBox(height: 8),
          CommitMessages(t, onEdit: ref.watch(canEditProvider) && !_busy ? (r, c) => _editCommit(t, r, c) : null),
        ]),
      ...checks,
      ..._resultBody(context, r, reading: false),
      _codeReview(d),
      _preview(d),
      ...controls,
    ];
  }

  /// Summary and notes of a result (what to read), then its checks and
  /// per-file diffs (what to check): the review shows its commits and
  /// safety checks between the two.
  List<Widget> _resultBody(BuildContext context, Result r, {bool reading = true, bool checking = true}) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final paras = _tr(r.summary).split(RegExp(r'\n\s*\n')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    final passed = r.checks.where((x) => x.exitCode == 0).length;
    return [
      if (reading && paras.isNotEmpty)
        TicketSection(id: 'summary', title: l.ticketWhatAgntsDid, children: [
          for (final p in paras) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(p, style: const TextStyle(fontSize: 15, height: 1.45))),
        ]),
      if (reading && r.notes.isNotEmpty) TicketSection(id: 'notes', title: l.ticketNotes, hint: '${r.notes.length}', children: _noteList(r.notes)),
      if (checking && r.checks.isNotEmpty)
        TicketSection(id: 'checks', title: l.ticketChecks, hint: '$passed/${r.checks.length}', children: [
          ListGroup(children: [
          for (final x in r.checks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                HIcon(x.exitCode == 0 ? 'check' : 'close', size: 16, stroke: 2.6, color: x.exitCode == 0 ? c.okInk : c.badInk),
                const SizedBox(width: 10),
                Expanded(child: Text(x.command, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink))),
                Text(x.exitCode == 0 ? l.ticketPassed : l.ticketFailedCheck,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: x.exitCode == 0 ? c.okInk : c.badInk)),
              ]),
            ),
          ]),
        ]),
      if (checking && r.files.isNotEmpty)
        TicketSection(id: 'diff', title: l.ticketDiff, hint: '${r.files.length}', children: [
          RepoDiffs(files: r.files, openFirst: true, file: (f, open) => FileDiff(file: f, initiallyOpen: open)),
        ]),
    ];
  }

  /// A result's notes for the reviewer, one bullet each.
  List<Widget> _noteList(List<String> notes) {
    final c = Agnts.of(context);
    return [
      for (final n in notes)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ', style: TextStyle(color: c.ink3)),
            Expanded(child: Text(_tr(n), style: const TextStyle(fontSize: 15, height: 1.4))),
          ]),
        ),
    ];
  }

  String _changed(AppLocalizations l, Result r) {
    final add = r.files.fold<int>(0, (a, f) => a + f.add), del = r.files.fold<int>(0, (a, f) => a + f.del);
    return l.ticketChangedValue(r.files.length, add.toString(), del.toString());
  }

  /// From the last start of coding to the result.
  Duration? _reviewTime(TicketDetail d) {
    final r = d.result;
    if (r == null) return null;
    DateTime? start;
    for (final h in d.history ?? const <HistoryItem>[]) {
      if (h.state == TicketState.coding && !h.at.isAfter(r.createdAt) && (start == null || h.at.isAfter(start))) start = h.at;
    }
    if (start == null) return null;
    final dur = r.createdAt.difference(start);
    return dur.isNegative ? null : dur;
  }

  // ---- Questions (.q, .opts, .opt, textarea) ----

  Widget _questionCard(BuildContext context, Question q) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final note = _noteFor(q);
    final enabled = !_busy;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_tr(q.text), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.4, color: c.ink)),
        if (q.multiple && q.options.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(l.ticketPickAny, style: TextStyle(fontSize: 13, color: c.ink3)),
          ),
        const SizedBox(height: 10),
        if (q.options.isNotEmpty) ...[
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in q.options)
              _OptionPill(
                label: _tr(o),
                selected: q.multiple ? (_chosen[q.id]?.contains(o) ?? false) : _picked[q.id] == o,
                onTap: enabled ? () => _toggle(q, o) : null,
              ),
          ]),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: note,
          enabled: enabled,
          minLines: 2,
          maxLines: 6,
          style: const TextStyle(fontSize: 16, height: 1.4),
          decoration: InputDecoration(
            hintText: q.options.isEmpty
                ? l.ticketYourAnswer
                : q.multiple
                    ? l.ticketOtherAnswer
                    : l.ticketAddDetails,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        AttachmentPicker(controller: _filesFor(q), enabled: enabled),
      ]),
    );
  }

  Widget _analysisFold(BuildContext context, Analysis a) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Fold(
        title: a.summary.isEmpty ? l.ticketPlan : l.ticketAnalysis,
        hint: a.plan.isEmpty ? null : '${a.plan.length}',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (a.summary.isNotEmpty) Text(_tr(a.summary), style: const TextStyle(fontSize: 15, height: 1.45)),
          if (a.plan.isNotEmpty) ...[
            if (a.summary.isNotEmpty) _H3(l.ticketPlan),
            for (final (i, p) in a.plan.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 22, child: Text('${i + 1}.', style: TextStyle(color: c.ink3, fontSize: 15))),
                  Expanded(child: Text(_tr(p), style: const TextStyle(fontSize: 15, height: 1.4))),
                ]),
              ),
          ],
        ]),
      ),
    );
  }

  // ---- Logs ----

  List<Event> _shown(List<Event> evs) => evs.where((e) => e.type != 'claude_text' || e.message.length < 400).toList();

  /// The live log of a running ticket on the dark code background (.log).
  Widget _liveLog(BuildContext context, bool live) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final events = ref.watch(ticketEventsProvider(widget.ticketKey));
    return events.when(
      data: (evs) {
        final shown = _shown(evs);
        final tail = shown.length > 80 ? shown.sublist(shown.length - 80) : shown;
        if (tail.isEmpty) return LogBox(lines: [('', l.ticketLogEmpty)], live: live);
        return LogBox(lines: [for (final e in tail) (_clock(context, e.createdAt), e.message)], live: live);
      },
      error: (_, _) => Text(l.commonError, style: TextStyle(color: c.badInk)),
      loading: () => const LinearProgressIndicator(),
    );
  }

  // ---- Folds at the bottom: answers, analysis, changes, history, run log ----

  Widget _folds(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final early = t.state == TicketState.new_ || t.state == TicketState.analyzing || t.state == TicketState.waitingForAnswers;
    final answered = d.questions.where((q) => (q.answer ?? '').isNotEmpty).toList();
    final retryFiles = d.attachments.where((a) => a.purpose == AttachmentPurposeEnum.retry).toList();
    final feedbackFiles = d.attachments.where((a) => a.purpose == AttachmentPurposeEnum.feedback).toList();
    final history = (d.history ?? const <HistoryItem>[]).toList()..sort((a, b) => b.at.compareTo(a.at));
    final events = ref.watch(ticketEventsProvider(widget.ticketKey));
    final folds = <Widget>[
      if (answered.isNotEmpty && !early)
        Fold(
          title: l.ticketAnswersTitle,
          hint: '${answered.length}',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final q in answered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(TextSpan(style: const TextStyle(fontSize: 15, height: 1.4), children: [
                    TextSpan(text: '${q.text}\n', style: TextStyle(color: c.ink3)),
                    TextSpan(
                      // A multiple-choice answer is one choice per line.
                      text: q.multiple ? q.answer!.split('\n').where((x) => x.trim().isNotEmpty).join(', ') : q.answer,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (q.note.isNotEmpty) TextSpan(text: '. ${q.note}'),
                  ])),
                  AttachmentList([
                    for (final a in d.attachments)
                      if (a.purpose == AttachmentPurposeEnum.answer && a.questionId == q.id) a,
                  ]),
                ]),
              ),
          ]),
        ),
      if (retryFiles.isNotEmpty || feedbackFiles.isNotEmpty)
        Fold(
          title: l.filesTitle,
          hint: '${retryFiles.length + feedbackFiles.length}',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AttachmentList(feedbackFiles, label: l.filesFromFeedback),
            AttachmentList(retryFiles, label: l.filesFromRetry),
          ]),
        ),
      if (t.kind == TicketKind.swaggertest) ApiResultsFold(ticketKey: t.key),
      if (d.analysis != null && t.state != TicketState.waitingForAnswers) _analysisFold(context, d.analysis!),
      if (d.result?.report != null && t.state != TicketState.waitingForReview && t.state != TicketState.done)
        Fold(title: l.ticketReport, child: ReportMarkdown(_tr(d.result!.report!)))
      // The last change's sections, as cards among the folds (not a fold of
      // cards): the review shows them in its stage instead.
      else if (d.result != null && !isReportKind(t.kind) && t.state != TicketState.waitingForReview)
        ..._resultBody(context, d.result!),
      if (t.kind == TicketKind.review && t.pull != null) ReviewDraftsFold(ticket: t),
      for (final p in ticketPulls(t)) PullCommentsFold(ticket: t, repoId: p.repoId, number: p.number, url: p.url, repoName: p.repoName),
      if (!isReportKind(t.kind)) LinkedCommitsFold(ticket: t),
      TicketDocumentsFold(ticket: t, hasReport: isReportKind(t.kind) && (d.result?.report?.trim().isNotEmpty ?? false)),
      if (RelationsFold.shows(d)) RelationsFold(d),
      if (d.followUps != null) FollowUpsFold(d),
      SpendFold(spend: t.spend, stages: d.spendByStage ?? const [], report: isReportKind(t.kind)),
      Fold(
        title: l.ticketHistoryTitle,
        hint: '${history.length}',
        child: history.isEmpty
            ? Text(l.ticketHistoryEmpty, style: TextStyle(color: c.ink3))
            : Column(children: [
                for (final (i, h) in history.indexed)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(border: i == history.length - 1 ? null : Border(bottom: BorderSide(color: c.line2))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        width: 56,
                        child: Text(_when(context, h.at), style: TextStyle(fontSize: 13, color: c.ink3, fontFeatures: const [FontFeature.tabularFigures()])),
                      ),
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(top: 6, right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: h.state == TicketState.done
                              ? c.ok
                              : h.origin == 'user'
                                  ? c.warn
                                  : c.line3,
                        ),
                      ),
                      Expanded(child: Text(h.message.isEmpty ? stateLabel(l, h.state, t.kind) : h.message, style: const TextStyle(fontSize: 14, height: 1.4))),
                    ]),
                  ),
              ]),
      ),
      Fold(
        title: l.ticketRunLog,
        hint: events.value == null ? null : '${_shown(events.value!).length}',
        child: events.when(
          data: (evs) {
            final shown = _shown(evs).reversed.take(40).toList();
            if (shown.isEmpty) return Text(l.ticketLogEmpty, style: TextStyle(color: c.ink3));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final e in shown)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 48, child: Text(_clock(context, e.createdAt), style: TextStyle(fontSize: 12.5, color: c.ink3))),
                    Expanded(
                      child: Text(
                        e.message,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: e.type == 'claude_tool' ? AgntsFonts.mono : null,
                          color: e.level == EventLevelEnum.error
                              ? c.badInk
                              : e.level == EventLevelEnum.warn
                                  ? c.warnInk
                                  : c.ink,
                        ),
                      ),
                    ),
                  ]),
                ),
            ]);
          },
          error: (_, _) => Text(l.commonError, style: TextStyle(color: c.badInk)),
          loading: () => const LinearProgressIndicator(),
        ),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // A section keeps its own space above.
        for (final (i, f) in folds.indexed) f is TicketSection ? f : Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 10), child: f),
      ]),
    );
  }

  String _clock(BuildContext context, DateTime at) =>
      MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(at.toLocal()), alwaysUse24HourFormat: true);

  /// Time today, otherwise the short date.
  String _when(BuildContext context, DateTime at) {
    final local = at.toLocal(), now = DateTime.now();
    if (local.year == now.year && local.month == now.month && local.day == now.day) return _clock(context, at);
    return MaterialLocalizations.of(context).formatShortMonthDay(local);
  }

  // ---- The sticky action bar (dBar) ----

  Widget? _actionBar(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final key = t.key;
    final danger = OutlinedButton.styleFrom(foregroundColor: c.badInk);
    Widget hint(String text) => Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: c.ink3)));
    // A ticket can be rejected at any stage before it is done.
    final reject = Tooltip(
      message: l.ticketReject,
      child: SizedBox(
        width: 48,
        child: OutlinedButton(
          style: danger.copyWith(padding: const WidgetStatePropertyAll(EdgeInsets.zero)),
          onPressed: _busy ? null : () => _reject(context, t),
          child: HIcon('close', size: 20, stroke: 2.2, color: _busy ? c.line3 : c.badInk),
        ),
      ),
    );
    List<Widget> buttons;
    switch (t.state) {
      case TicketState.waitingForAnswers:
        final left = d.questions.where((q) => _answerOf(q).isEmpty).length;
        final uploading = d.questions.any((q) => _filesFor(q).uploading);
        buttons = [
          reject,
          hint([
            uploading
                ? l.filesWait
                : left > 0
                    ? l.ticketQuestionsLeft(left)
                    : l.ticketAllAnswered,
            if (_draftState != null)
              switch (_draftState!) {
                _DraftState.saving => l.ticketDraftSaving,
                _DraftState.saved => l.ticketDraftSaved,
                _DraftState.failed => l.ticketDraftFailed,
              },
          ].join('\n')),
          FilledButton(
            onPressed: _busy || left > 0 || uploading
                ? null
                : () async {
                    // Sending the answers clears their drafts.
                    _draftTimer?.cancel();
                    _draftTimer = null;
                    final ok = await _run(() => _tickets.answerQuestions(
                          key: key,
                          answersRequest: AnswersRequest(answers: [
                            for (final q in d.questions)
                              AnswersRequestAnswersInner(
                                questionId: q.id,
                                answer: _answerOf(q),
                                note: _noteOf(q),
                                attachments: _filesFor(q).ids.isEmpty ? null : _filesFor(q).ids,
                              ),
                          ]),
                        ));
                    if (ok) {
                      for (final f in _answerFiles.values) {
                        f.clear();
                      }
                    }
                  },
            child: Text(isReportKind(t.kind) ? l.ticketStartWriting : l.ticketStartCoding),
          ),
        ];
      case TicketState.waitingForReview:
        final report = isReportKind(t.kind);
        final toMain = t.afterApprove == TicketAfterApproveEnum.main && t.source_ == TicketSource_Enum.local;
        final plane = t.source_ == TicketSource_Enum.plane;
        final post = report && _postReport && (plane || t.source_ == TicketSource_Enum.jira);
        // A review asked for from the pull request page never merges.
        final finish = t.kind == TicketKind.review && t.afterApprove == TicketAfterApproveEnum.none;
        final assign = opensPr(t) ? _assignees.toList() : const <String>[];
        final confirm = finish
            ? l.draftsFinishConfirm('${t.pull?.number ?? t.prNumber ?? ''}')
            : report
                ? (post ? (plane ? l.ticketApproveReportPostConfirmPlane(key) : l.ticketApproveReportPostConfirm(key)) : l.ticketApproveReportConfirm)
                : (toMain ? l.ticketApproveMainConfirm : l.ticketApproveConfirm(t.branch)) +
                    (assign.isEmpty ? '' : '\n\n${l.ticketApproveAssignees(assign.join(', '))}');
        buttons = [
          reject,
          Expanded(
            child: OutlinedButton(
              onPressed: _busy ? null : () => _requestChanges(context, t),
              child: Text(l.ticketRequestChanges, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      if (await _confirm(confirm)) {
                        await _run(() => _tickets.approveTicket(
                              key: key,
                              approveTicketRequest: report
                                  ? ApproveTicketRequest(postReport: post)
                                  : opensPr(t)
                                      ? ApproveTicketRequest(assignees: assign)
                                      : null,
                            ));
                      }
                    },
              child: Text(finish ? l.draftsFinishBtn : report ? l.ticketApproveReport : l.mdetailApprove, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];
      case TicketState.failed:
      case TicketState.rateLimited:
        final failed = t.state == TicketState.failed;
        buttons = [
          Expanded(
            child: OutlinedButton(
              style: danger,
              onPressed: _busy ? null : () => _reject(context, t),
              child: Text(failed ? l.ticketTakeItMyself : l.ticketReject, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          Expanded(
            child: Tooltip(
              message: _retryFiles.uploading ? l.filesWait : '',
              child: FilledButton(
                onPressed: _busy || (_takesRetryNote(t) && _retryFiles.uploading) || (failed && needsRepo(t) && t.repoId == null) ? null : () => _retry(t),
                child: Text(failed ? l.mobileRetry : l.ticketResume, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ];
      case TicketState.rejected when t.continueTo != null:
        buttons = [
          if (t.canStartOver == true)
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => _startOver(context, key),
                child: Text(l.ticketStartOver, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          Expanded(
            child: Tooltip(
              message: _continueFiles.uploading ? l.filesWait : '',
              child: FilledButton(
                onPressed: _busy || (_takesContinueNote(t) && _continueFiles.uploading) ? null : () => _continue(t),
                child: Text(l.ticketContinue, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ];
      case TicketState.analyzing:
      case TicketState.coding:
      case TicketState.testing:
        buttons = [
          reject,
          Expanded(
            child: OutlinedButton(
              style: danger,
              onPressed: _busy
                  ? null
                  : () async {
                      if (await _confirm(l.ticketStopConfirm(key))) await _run(() => _tickets.stopTicket(key: key));
                    },
              child: Text(l.ticketStopRun),
            ),
          ),
        ];
      case TicketState.pushing:
        buttons = [reject, hint(l.mdetailWorking)];
      case TicketState.new_ when t.held == true:
        buttons = [
          reject,
          Expanded(child: FilledButton(onPressed: _busy ? null : () => _run(() => _tickets.startTicket(key: key)), child: Text(l.ticketStart))),
        ];
      case TicketState.new_:
        buttons = [reject, hint(l.ticketStartHint)];
      case TicketState.done when t.prUrl.isNotEmpty:
        buttons = [
          Expanded(
            child: OutlinedButton(
              onPressed: () => openLink(context, t.prUrl),
              child: Text(l.analyticsOpenPr, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];
      default:
        return null;
    }
    return ActionBar(children: buttons);
  }

  Future<void> _reject(BuildContext context, Ticket t) async {
    final l = AppLocalizations.of(context);
    final key = t.key;
    if (await _confirm(t.state == TicketState.pushing ? l.ticketRejectPushingConfirm(key) : l.ticketRejectConfirm(key))) {
      await _run(() => _tickets.rejectTicket(key: key, rejectTicketRequest: RejectTicketRequest(reason: 'rejected from the phone')));
      if (context.mounted) context.pop();
    }
  }

  /// The "skip checks" tick of the retry and request-changes forms, with
  /// what it means; it starts at the ticket's own setting.
  Widget _skipChecksBox(Ticket t, {required ValueChanged<bool> onChanged}) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CheckboxListTile(
        value: _skipChecks ?? t.skipChecks,
        onChanged: _busy ? null : (v) => onChanged(v ?? false),
        title: Text(l.ticketSkipChecks, style: const TextStyle(fontSize: 15)),
        subtitle: Text(l.ticketSkipChecksHint, style: TextStyle(fontSize: 13, color: Agnts.of(context).ink3)),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _requestChanges(BuildContext context, Ticket t) async {
    final l = AppLocalizations.of(context);
    // Only a code change has checks to skip (not a report, not a review
    // of someone's pull request).
    final checks = !isReportKind(t.kind) && !isPullReview(t);
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(c).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.ticketRequestChanges, style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l.ticketFeedbackHint, style: TextStyle(fontSize: 14, color: Agnts.of(c).ink3)),
          const SizedBox(height: 12),
          TextField(
            controller: _feedback,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            style: const TextStyle(fontSize: 16, height: 1.4),
            decoration: InputDecoration(hintText: l.ticketFeedbackPlaceholder),
          ),
          FeedbackShotChips(shots: _feedbackShots),
          const SizedBox(height: 12),
          AttachmentPicker(controller: _feedbackFiles),
          if (checks) StatefulBuilder(builder: (c, set) => _skipChecksBox(t, onChanged: (v) => set(() => _skipChecks = v))),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _feedbackFiles,
            builder: (c, _) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (_feedbackFiles.uploading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(l.filesWait, style: TextStyle(fontSize: 13, color: Agnts.of(c).ink3)),
                ),
              FilledButton(
                onPressed: _feedbackFiles.uploading ? null : () => Navigator.pop(c, _feedback.text.trim()),
                child: Text(l.ticketSend),
              ),
            ]),
          ),
        ]),
      ),
    );
    if (text == null || text.isEmpty) return;
    final shots = [for (final s in _feedbackShots.value) s.ref];
    final ids = _feedbackFiles.ids;
    final ok = await _run(() => _tickets.requestChanges(
        key: t.key,
        requestChangesRequest: RequestChangesRequest(
            feedback: text, shots: shots.isEmpty ? null : shots, attachments: ids.isEmpty ? null : ids, skipChecks: checks ? _skipChecks : null)));
    if (!ok) return;
    _skipChecks = null;
    _feedback.clear();
    _feedbackShots.value = const [];
    _feedbackFiles.clear();
  }
}

/// Whether a retry may carry a note and files: a failed run that does not
/// resume at pushing (the server refuses them there, as the admin panel).
bool _takesRetryNote(Ticket t) => t.state == TicketState.failed && t.resumeState != TicketState.pushing;

/// Only a rejected ticket going back to a stage that runs Claude takes a note.
bool _takesContinueNote(Ticket t) =>
    t.state == TicketState.rejected && const [TicketState.new_, TicketState.coding, TicketState.waitingForReview].contains(t.continueTo);

/// Where Continue sends a rejected ticket, in a sentence.
String? _continueHint(AppLocalizations l, TicketState? to) => switch (to) {
      TicketState.new_ => l.ticketContinueToNew,
      TicketState.waitingForAnswers => l.ticketContinueToAnswers,
      TicketState.coding => l.ticketContinueToCoding,
      TicketState.waitingForReview => l.ticketContinueToReview,
      TicketState.failed => l.ticketContinueToFailed,
      TicketState.rateLimited => l.ticketContinueToRateLimited,
      _ => null,
    };

/// A model's name: Haiku, Sonnet, Opus, or "Codex" and the model for a
/// run on Codex CLI ("codex:" and the model).
String _modelName(String m) {
  if (m.startsWith('codex:')) return 'Codex ${m.substring(6)}';
  return m.isEmpty ? m : '${m[0].toUpperCase()}${m.substring(1)}';
}

// ---- Small private pieces of the demo's detail page ----

/// A block under the track (.block).
class _Block extends StatelessWidget {
  const _Block({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

/// .block h2
class _H2 extends StatelessWidget {
  const _H2(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Agnts.of(context).ink)),
      );
}

/// .block .sub
class _Sub extends StatelessWidget {
  const _Sub(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: TextStyle(fontSize: 14, height: 1.45, color: Agnts.of(context).ink3)),
      );
}

/// .h3: a small grey heading inside a block.
class _H3 extends StatelessWidget {
  const _H3(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Agnts.of(context).ink3)),
      );
}

/// Where saving the unsent answers is.
enum _DraftState { saving, saved, failed }

/// An answer option (.opt): black when picked.
class _OptionPill extends StatelessWidget {
  const _OptionPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Material(
      color: selected ? c.ink : c.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? c.ink : c.line4)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: selected ? c.surface : c.ink2)),
        ),
      ),
    );
  }
}

// ---- The progress track (mtrack: .track, .stop, .mark) ----

enum _Stop { none, done, active, error }

class _Track extends StatelessWidget {
  const _Track({required this.ticket, required this.history});
  final Ticket ticket;
  final List<HistoryItem> history;

  bool get _report => isReportKind(ticket.kind);

  /// A report has no tests and nothing to push: five stops.
  int? _indexOf(TicketState s) {
    final i = _index(s);
    if (!_report || i == null || i < 3) return i;
    return switch (s) {
      TicketState.testing => 2,
      _ => i - 1,
    };
  }

  static int? _index(TicketState s) => switch (s) {
        TicketState.new_ => -1,
        TicketState.analyzing => 0,
        TicketState.waitingForAnswers => 1,
        TicketState.coding => 2,
        TicketState.testing => 3,
        TicketState.waitingForReview => 4,
        TicketState.pushing => 5,
        TicketState.done => 6,
        TicketState.rejected => -2,
        TicketState.failed || TicketState.rateLimited => null,
      };

  /// Where a stopped run stopped: its resume state, else the last state it reached.
  int _failedAt() {
    final last = _report ? 4 : 5;
    final r = ticket.resumeState == null ? null : _indexOf(ticket.resumeState!);
    if (r != null && r >= 0) return r.clamp(0, last);
    final h = history.toList()..sort((a, b) => b.at.compareTo(a.at));
    for (final x in h) {
      final i = _indexOf(x.state);
      if (i != null && i >= 0) return i.clamp(0, last);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final labels = _report
        ? [l.ticketStopAnalyze, l.ticketStopAnswers, l.ticketStopWriting, l.ticketStopReview, l.ticketStopDone]
        : [l.ticketStopAnalyze, l.ticketStopAnswers, l.ticketStopCoding, l.ticketStopTests, l.ticketStopReview, l.ticketStopPushed];
    final gates = _report ? const [false, true, false, true, false] : const [false, true, false, false, true, false];
    final n = labels.length;
    var idx = _indexOf(ticket.state);
    var err = false;
    if (idx == null) {
      idx = _failedAt();
      err = true;
    }
    _Stop kind(int i) {
      if (idx == -2) return i == 0 ? _Stop.done : _Stop.none;
      if (i < idx! || idx == n) return _Stop.done;
      if (i == idx) return err ? _Stop.error : _Stop.active;
      return _Stop.none;
    }

    final kinds = [for (var i = 0; i < n; i++) kind(i)];
    bool lit(int i) => kinds[i] != _Stop.none;
    return Semantics(
      label: l.ticketProgress,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 18, 16, 4),
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 12),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(18)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < n; i++)
            Expanded(
              child: Column(children: [
                SizedBox(
                  height: 22,
                  child: Stack(alignment: Alignment.center, children: [
                    // The connector: left half belongs to this stop, right half to the next.
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Row(children: [
                        Expanded(child: Container(height: 2, color: i == 0 ? Colors.transparent : (lit(i) ? c.primary : c.line))),
                        Expanded(child: Container(height: 2, color: i == n - 1 ? Colors.transparent : (lit(i + 1) ? c.primary : c.line))),
                      ]),
                    ),
                    _Mark(kind: kinds[i], gate: gates[i]),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: kinds[i] == _Stop.active && gates[i]
                        ? c.warnInk
                        : (kinds[i] == _Stop.active || kinds[i] == _Stop.error)
                            ? c.ink
                            : c.ink3,
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.kind, required this.gate});
  final _Stop kind;
  final bool gate;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final (bg, border) = switch (kind) {
      _Stop.done => (c.primary, c.primary),
      _Stop.active => gate ? (c.warn, c.warn) : (c.primarySoft, c.primary),
      _Stop.error => (c.badSoft, c.bad),
      _Stop.none => (c.surface, c.line3),
    };
    Widget? inner;
    if (kind == _Stop.done) {
      inner = HIcon('check', size: 11, stroke: 3.2, color: c.onPrimary);
      if (gate) inner = Transform.rotate(angle: -0.785398, child: inner);
    } else if (kind == _Stop.active && !gate) {
      inner = const Pulse(size: 7);
    }
    final size = gate ? 18.0 : 22.0;
    final box = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(gate ? 5 : 11),
      ),
      child: inner,
    );
    return gate ? Transform.rotate(angle: 0.785398, child: box) : box;
  }
}
