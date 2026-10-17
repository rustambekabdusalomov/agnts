import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../ci/ci_screen.dart' show CIFailureCard;

final _watchProvider = FutureProvider.autoDispose.family<CIWatch, int>((ref, id) async {
  return (await requireApi(ref).getCiApi().getRepoCIWatch(id: id)).data!;
});

typedef _FailKey = ({int repoId, String filter});

final _repoFailuresProvider = FutureProvider.autoDispose.family<List<CIFailure>, _FailKey>((ref, k) async {
  final statuses = ciFilterStatuses[k.filter] ?? const <CIStatus>[];
  final res = await requireApi(ref).getCiApi().listCIFailures(
        repoId: k.repoId,
        status: statuses.isEmpty ? null : statuses.map((s) => s.value).join(','),
      );
  return res.data ?? const [];
});

/// Globs typed one per line, without blanks.
List<String> globLines(String text) => text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

/// The repository's CI watching (CiTab.vue): which branches and jobs agnts
/// watches, what it does on other people's pull requests, whether it opens
/// tickets by itself; then what fails here and the flaky tests.
class RepoCiTab extends ConsumerStatefulWidget {
  const RepoCiTab({super.key, required this.repo});
  final Repository repo;

  @override
  ConsumerState<RepoCiTab> createState() => _RepoCiTabState();
}

class _RepoCiTabState extends ConsumerState<RepoCiTab> {
  final _branches = TextEditingController();
  final _ignore = TextEditingController();
  bool _enabled = false;
  String _prs = 'off';
  bool? _autoFix;
  CIWatch? _loaded;
  bool _saving = false;
  String _filter = 'red';

  @override
  void dispose() {
    _branches.dispose();
    _ignore.dispose();
    super.dispose();
  }

  void _take(CIWatch w) {
    _loaded = w;
    _enabled = w.enabled;
    _branches.text = w.branches.join('\n');
    _ignore.text = w.ignore.join('\n');
    _prs = w.prs == 'comment' ? 'comment' : 'off';
    _autoFix = w.autoFix;
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final w = (await ref.read(apiProvider)!.getCiApi().putRepoCIWatch(
                id: widget.repo.id,
                cIWatch: CIWatch(
                  enabled: _enabled,
                  branches: globLines(_branches.text),
                  ignore: globLines(_ignore.text),
                  prs: _prs,
                  autoFix: _autoFix,
                ),
              ))
          .data!;
      if (!mounted) return;
      setState(() => _take(w));
      showSnack(context, l.ciWatchSaved);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final id = widget.repo.id;
    final watch = ref.watch(_watchProvider(id));
    final w = watch.value;
    if (w != null && _loaded == null) _take(w);
    final canEdit = ref.watch(canEditProvider) && !_saving;
    final hint = TextStyle(fontSize: 13, color: c.ink3);

    Widget field(String label, String help, TextEditingController ctl, String placeholder) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
            const SizedBox(height: 2),
            Text(help, style: hint),
            const SizedBox(height: 6),
            TextField(
              controller: ctl,
              enabled: canEdit,
              minLines: 3,
              maxLines: 6,
              autocorrect: false,
              style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13),
              decoration: InputDecoration(hintText: placeholder),
            ),
          ]),
        );
    Widget choice<T>(String label, String help, List<(T, String)> options, T value, ValueChanged<T> onChanged) => Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
            const SizedBox(height: 2),
            Text(help, style: hint),
            const SizedBox(height: 8),
            Segmented<T>(full: true, options: options, value: value, onChanged: canEdit ? onChanged : (_) {}),
          ]),
        );

    final failures = ref.watch(_repoFailuresProvider((repoId: id, filter: _filter)));
    final flaky = ref.watch(_repoFailuresProvider((repoId: id, filter: 'flaky')));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.ciWatchTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l.ciWatchSub, style: hint),
            if (watch.hasError && w == null)
              Padding(padding: const EdgeInsets.only(top: 10), child: HelpBox(errorMessage(watch.error!, l.commonError), tone: Tone.bad))
            else if (w == null)
              const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
            else ...[
              if (w.problem != null && w.problem!.isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 10), child: HelpBox(w.problem!, tone: Tone.warn)),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.ciWatchEnabled, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
                  subtitle: Text(l.ciWatchEnabledHelp, style: hint),
                  value: _enabled,
                  onChanged: canEdit ? (v) => setState(() => _enabled = v) : null,
                ),
              ),
              field(l.ciBranches, l.ciBranchesHelp(widget.repo.defaultBranch), _branches, 'release/*'),
              field(l.ciIgnore, l.ciIgnoreHelp, _ignore, '*deploy*\n*release*\n*publish*'),
              choice<String>(l.ciPrs, l.ciPrsHelp, [('off', l.ciPrs_off), ('comment', l.ciPrs_comment)], _prs, (v) => setState(() => _prs = v)),
              choice<int>(
                l.ciAutoFix,
                l.ciAutoFixRepoHelp,
                [(0, l.ciAutoFix_inherit), (1, l.ciAutoFix_on), (2, l.ciAutoFix_off)],
                _autoFix == null ? 0 : (_autoFix! ? 1 : 2),
                (v) => setState(() => _autoFix = v == 0 ? null : v == 1),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(onPressed: canEdit ? _save : null, child: Text(l.ciSave)),
              ),
            ],
          ]),
        ),
        SectionHeader(l.ciFailuresTitle, padding: const EdgeInsets.fromLTRB(4, 22, 4, 4)),
        Text(l.ciFailuresSub, style: hint),
        const SizedBox(height: 10),
        Segmented<String>(
          full: true,
          options: [('red', l.mciFilterRed), ('flaky', l.mciFilterFlaky), ('all', l.mciFilterAll)],
          value: _filter,
          onChanged: (v) => setState(() => _filter = v),
        ),
        const SizedBox(height: 10),
        ..._failureList(context, failures, _filter == 'red' ? l.mciEmptyRed : l.mciEmpty),
        SectionHeader(l.ciFlakyTitle, padding: const EdgeInsets.fromLTRB(4, 22, 4, 4)),
        Text(l.ciFlakySub, style: hint),
        const SizedBox(height: 10),
        ..._failureList(context, flaky, l.ciFlakyEmpty),
      ]),
    );
  }

  List<Widget> _failureList(BuildContext context, AsyncValue<List<CIFailure>> v, String empty) {
    final l = AppLocalizations.of(context);
    return switch (v) {
      AsyncData(:final value) when value.isEmpty => [Padding(padding: const EdgeInsets.all(12), child: Text(empty, style: TextStyle(color: Agnts.of(context).ink3)))],
      AsyncData(:final value) => [for (final f in value) Padding(padding: const EdgeInsets.only(bottom: 10), child: CIFailureCard(f))],
      AsyncError(:final error) => [HelpBox(errorMessage(error, l.commonError), tone: Tone.bad)],
      _ => [const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))],
    };
  }
}
