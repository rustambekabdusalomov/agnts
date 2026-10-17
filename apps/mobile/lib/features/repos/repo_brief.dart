import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../tickets/kinds.dart' show ReportMarkdown;

final repoBriefProvider = FutureProvider.autoDispose.family<RepoBrief, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().getRepoBrief(id: id)).data!;
});

/// A survey is queued or running: the brief is polled until it settles.
bool briefBusy(RepoBrief? b) => b?.status == RepoBriefStatusEnum.pending || b?.status == RepoBriefStatusEnum.surveying;

enum _Act { survey, approve, discard, save }

/// What agnts knows about how the repository works (BriefTab.vue). A survey
/// writes a draft; once approved, every run of the repository's tickets reads it.
class RepoBriefTab extends ConsumerStatefulWidget {
  const RepoBriefTab({super.key, required this.repoId});
  final int repoId;

  @override
  ConsumerState<RepoBriefTab> createState() => _RepoBriefTabState();
}

class _RepoBriefTabState extends ConsumerState<RepoBriefTab> {
  final _text = TextEditingController();
  bool _editing = false;
  bool _busy = false;
  Timer? _poll;

  @override
  void dispose() {
    _poll?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _act(_Act a) async {
    final l = AppLocalizations.of(context);
    if (a == _Act.discard) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l.briefDiscard),
          content: Text(l.briefDiscardBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.briefDiscard)),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _busy = true);
    final api = ref.read(apiProvider)!.getReposApi();
    final id = widget.repoId;
    try {
      await switch (a) {
        _Act.survey => api.surveyRepoBrief(id: id),
        _Act.approve => api.approveRepoBrief(id: id),
        _Act.discard => api.discardRepoBriefDraft(id: id),
        _Act.save => api.saveRepoBrief(id: id, repoBriefInput: RepoBriefInput(body: _text.text)),
      };
      ref.invalidate(repoBriefProvider(id));
      if (!mounted) return;
      if (a == _Act.save) setState(() => _editing = false);
      showSnack(context, switch (a) {
        _Act.survey => l.briefDone_survey,
        _Act.approve => l.briefDone_approve,
        _Act.discard => l.briefDone_discard,
        _Act.save => l.briefDone_save,
      });
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
    final brief = ref.watch(repoBriefProvider(widget.repoId));
    final b = brief.value;
    // Poll while a survey runs.
    _poll?.cancel();
    if (briefBusy(b)) _poll = Timer(const Duration(seconds: 5), () => ref.invalidate(repoBriefProvider(widget.repoId)));
    final canEdit = ref.watch(canEditProvider);
    final hint = TextStyle(fontSize: 13, color: c.ink3);
    String ago(DateTime? at) => at == null ? '—' : _ago(l, at);
    String short(String sha) => sha.length > 7 ? sha.substring(0, 7) : sha;

    if (b == null) {
      return brief.hasError
          ? Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HelpBox(errorMessage(brief.error!, l.commonError), tone: Tone.bad))
          : const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(l.briefTitle, style: Theme.of(context).textTheme.titleMedium)),
              if (briefBusy(b))
                ToneBadge(b.status == RepoBriefStatusEnum.pending ? l.briefStatus_pending : l.briefStatus_surveying, Tone.info, small: true),
            ]),
            const SizedBox(height: 4),
            Text(l.briefSub, style: hint),
            if (!_editing && canEdit) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton(
                  onPressed: briefBusy(b) || _busy ? null : () => _act(_Act.survey),
                  child: Text(b.body.isNotEmpty ? l.briefUpdate : l.briefSurvey),
                ),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _text.text = b.body;
                    _editing = true;
                  }),
                  child: Text(b.body.isNotEmpty ? l.briefEdit : l.briefWrite),
                ),
              ]),
            ],
            if (b.status == RepoBriefStatusEnum.failed)
              Padding(padding: const EdgeInsets.only(top: 10), child: HelpBox(l.briefFailed(b.error), tone: Tone.bad, copyable: true)),
            const SizedBox(height: 12),
            if (_editing) ...[
              TextField(
                controller: _text,
                minLines: 10,
                maxLines: 24,
                autocorrect: false,
                style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, height: 1.5),
                decoration: InputDecoration(hintText: l.briefTitle),
              ),
              const SizedBox(height: 6),
              Text(l.briefEditHint, style: hint),
              const SizedBox(height: 10),
              Row(children: [
                FilledButton(onPressed: _busy ? null : () => _act(_Act.save), child: Text(l.briefSave)),
                const SizedBox(width: 8),
                TextButton(onPressed: () => setState(() => _editing = false), child: Text(l.briefCancel)),
              ]),
            ] else if (b.body.isNotEmpty) ...[
              Text(
                [
                  l.briefApproved(ago(b.approvedAt)),
                  if (b.bodySha.isNotEmpty) l.briefAtCommit(short(b.bodySha)),
                  l.briefMerges('${b.mergesSince}', '${b.refreshAfter}'),
                ].join(' · '),
                style: hint,
              ),
              const SizedBox(height: 8),
              ReportMarkdown(b.body),
            ] else if (b.draft.isEmpty)
              Text(briefBusy(b) ? l.briefSurveying : l.briefNone, style: TextStyle(color: c.ink3)),
          ]),
        ),
        if (b.draft.isNotEmpty && !_editing) ...[
          const SizedBox(height: 12),
          HCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l.briefDraftTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                [l.briefDraftSub(ago(b.surveyedAt)), if (b.draftSha.isNotEmpty) l.briefAtCommit(short(b.draftSha))].join(' · '),
                style: hint,
              ),
              if (canEdit) ...[
                const SizedBox(height: 10),
                Row(children: [
                  FilledButton(onPressed: _busy ? null : () => _act(_Act.approve), child: Text(l.briefApprove)),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _busy ? null : () => _act(_Act.discard), child: Text(l.briefDiscard)),
                ]),
              ],
              const SizedBox(height: 12),
              ReportMarkdown(b.draft),
            ]),
          ),
        ],
      ]),
    );
  }
}

String _ago(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}
